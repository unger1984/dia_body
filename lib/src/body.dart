import 'dart:convert';
import 'dart:io';

import 'package:dia/dia.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:uuid/uuid.dart';

import 'parsed_body_mixin.dart';
import 'uploaded_file.dart';

Map<String, dynamic>? _foldToStringDynamic(Map? map) {
  return map == null
      ? null
      : map.keys.fold<Map<String, dynamic>>(
          <String, dynamic>{}, (out, k) => out..[k.toString()] = map[k]);
}

/// Middleware for parsing request body
/// [uploadDirectory] - directory for uploading files, default = Directory.systemTemp;
Middleware<T> body<T extends ParsedBody>({Directory? uploadDirectory}) =>
    (T ctx, next) async {
      ctx.query.addAll(ctx.request.uri.queryParameters);
      final dataStream = ctx.request.cast<List<int>>();

      final media = ctx.request.headers.contentType != null
          ? MediaType.parse(ctx.request.headers.value('content-type')!)
          : null;

      uploadDirectory ??= Directory.systemTemp.createTempSync();

      Future<String> getBody() {
        return dataStream.transform(utf8.decoder).join();
      }

      if (media != null) {
        if (media.type == 'multipart' &&
            media.parameters.containsKey('boundary')) {
          var parts = dataStream.transform(
              MimeMultipartTransformer(media.parameters['boundary']!));

          final filesParts = <String, Map<String, List<MimeMultipart>>>{};

          await for (MimeMultipart part in parts) {
            var header =
                HeaderValue.parse(part.headers['content-disposition']!);
            var name = header.parameters['name']!;

            var filename = header.parameters['filename'];
            if (filename != null) {
              var map = filesParts[name] ?? {};
              var list = map[filename] ?? [];
              list.add(part);
              map[filename] = list;
              filesParts[name] = map;
            } else {
              // if this part is not file
              var builder = await part.fold(
                  BytesBuilder(copy: false),
                  (BytesBuilder b, List<int> d) =>
                      b..add(d is! String ? d : (d as String).codeUnits));
              ctx.parsed[name] = utf8.decode(builder.takeBytes());
            }
          }

          for (var name in filesParts.keys) {
            var map = filesParts[name]!;
            final files = <UploadedFile>[];
            for (var filename in map.keys) {
              var list = map[filename]!;
              final file = File('${uploadDirectory!.path}/${Uuid().v4()}');
              for (var part in list) {
                if (!file.existsSync()) file.createSync(recursive: true);
                final fileSink = file.openWrite();
                await part.pipe(fileSink);
                await fileSink.close();
              }
              files.add(UploadedFile(filename, file));
            }
            ctx.files[name] = files;
          }
        } else if (media.mimeType == 'application/json') {
          ctx.parsed.addAll(
              _foldToStringDynamic(json.decode(await getBody()) as Map) ?? {});
        } else if (media.mimeType == 'application/x-www-form-urlencoded') {
          ctx.parsed.addAll(Uri.splitQueryString(await getBody()));
        }
      }

      await next();
    };
