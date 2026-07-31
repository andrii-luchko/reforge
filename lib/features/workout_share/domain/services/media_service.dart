import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';

abstract interface class IMediaService {
  Future<Uint8List?> captureFromKey(GlobalKey key);
  Future<void> shareFile(File file);

  Future<File> saveToTempDir(Uint8List bytes, {String fileName = 'share_image.png'});

  Future<void> saveToGallery(Uint8List bytes);
}
