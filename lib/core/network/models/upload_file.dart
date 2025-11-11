import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart';

class UploadFile {
  final String name;
  final File? file;
  final Uint8List? bytes;

  UploadFile({
    required this.name,
    this.file,
    this.bytes,
  });

  bool get isWeb => kIsWeb;
}
