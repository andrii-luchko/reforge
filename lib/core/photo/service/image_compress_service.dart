import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:reforge/app/utils/helpers/result.dart';

abstract interface class ImageService {
  Future<bool> checkSizeLimits(File file);
  Future<File> forceResize(File file);

  Future<Result<File>> checkSizeAndCompressIfNeeded(File file);

  Future<MultipartFile> convertToMultipart(File file);
}

@LazySingleton(as: ImageService)
class ImageServiceImpl implements ImageService {
  @override
  Future<MultipartFile> convertToMultipart(File file) async {
    return MultipartFile.fromFile(
      file.path,
      filename: file.path.split('/').last,
    );
  }

  static const int maxFileSize = 8 * 1024 * 1024;
  static const int targetQuality = 85;

  @override
  Future<bool> checkSizeLimits(File file) async {
    final size = await file.length();
    return size > maxFileSize;
  }

  @override
  Future<File> forceResize(File file) async {
    final tempDir = await getTemporaryDirectory();
    final targetPath = p.join(tempDir.path, '${DateTime.now().millisecondsSinceEpoch}_compressed.jpg');

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: targetQuality,
      // ignore: avoid_redundant_argument_values
      format: CompressFormat.jpeg,
    );

    return result != null ? File(result.path) : file;
  }

  @override
  Future<Result<File>> checkSizeAndCompressIfNeeded(File file) async {
    var fileToUpload = file;

    if (!fileToUpload.existsSync()) {
      return Failure(Exception('File not found'));
    }

    if (await fileToUpload.length() == 0) {
      return Failure(Exception('Image file is empty'));
    }

    final isOverLimit = await checkSizeLimits(fileToUpload);

    if (isOverLimit) {
      final compressedFile = await forceResize(fileToUpload);

      if (await checkSizeLimits(compressedFile)) {
        return Failure(Exception('Image file too large'));
      }

      fileToUpload = compressedFile;
    }

    return Success(fileToUpload);
  }
}
