import 'package:dia/dia.dart';

import 'uploaded_file.dart';

/// mixin to Context with additional parsed fields
mixin ParsedBody on Context {
  final Map<String, String> _query = {};
  final Map<String, dynamic> _parsed = {};
  final Map<String, List<UploadedFile>> _files = {};

  /// Uri params
  Map<String, String> get query => _query;

  /// Parsed body params
  Map<String, dynamic> get parsed => _parsed;

  /// Uploaded files
  Map<String, List<UploadedFile>> get files => _files;
}
