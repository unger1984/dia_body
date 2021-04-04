import 'dart:io';

class UploadedFile {
  final String filename;
  final File file;

  UploadedFile(this.filename, this.file);

  @override
  String toString() => 'filename:${this.filename} path:${this.file.path}';
}