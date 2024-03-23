import 'dart:typed_data';

class FileAttachment {
  String fileName;
  Uint8List fileBytes;
  FileAttachment({
    required this.fileName,
    required this.fileBytes,
  });
}
