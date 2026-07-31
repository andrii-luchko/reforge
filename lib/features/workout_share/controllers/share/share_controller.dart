import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/features/workout_share/domain/services/media_service.dart';

@injectable
class ShareController {
  ShareController(this._mediaService);
  final IMediaService _mediaService;

  Future<void> captureAndShare(GlobalKey key) async {
    final bytes = await _mediaService.captureFromKey(key);
    if (bytes == null) return;

    final file = await _mediaService.saveToTempDir(bytes);
    await _mediaService.shareFile(file);
  }

  Future<bool> captureAndSaveToGallery(GlobalKey key) async {
    final bytes = await _mediaService.captureFromKey(key);
    if (bytes == null) return false;

    await _mediaService.saveToGallery(bytes);
    return true;
  }
}
