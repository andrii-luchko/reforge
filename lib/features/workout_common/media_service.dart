import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reforge/features/workout_common/domain/media_service.dart';
import 'package:share_plus/share_plus.dart';

@Injectable(as: IMediaService)
class MediaService implements IMediaService {
  @override
  Future<Uint8List?> captureFromKey(GlobalKey key) async {
    try {
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      if (boundary.debugNeedsPaint) {
        await Future.delayed(const Duration(milliseconds: 20));
      }

      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();

      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> shareFile(File file) async {
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)]),
    );
  }

  @override
  Future<File> saveToTempDir(Uint8List bytes, {String fileName = 'share_progress.png'}) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName');
    return file.writeAsBytes(bytes);
  }

  @override
  Future<void> saveToGallery(Uint8List bytes) async {
    await ImageGallerySaverPlus.saveImage(bytes);
  }
}
