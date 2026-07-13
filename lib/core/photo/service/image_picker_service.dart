import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reforge/app/utils/exceptions/app_exception.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/photo/enum/picker_option.dart';
import 'package:reforge/core/photo/ui/image_source_picker_dialog.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

typedef PickedData = ({PickerOption option, File? file});

class ImagePickerService {
  static Future<Result<PickedData?>> pickAndCrop(
    BuildContext context, {
    List<PickerOption> availableOptions = PickerOption.values,
    ImageSourcePickerDialogData dialogData = const ImageSourcePickerDialogData(),
  }) async {
    try {
      final pickedData = await _showSourcePicker(
        context,
        availableOptions: availableOptions,
        dialogData: dialogData,
      );
      if (pickedData == null) return const Result.success(null);

      if (!context.mounted) return Result.success(pickedData);

      final option = pickedData.option;
      final file = pickedData.file;

      if (file == null || option == PickerOption.deletePhoto) {
        return Result.success(pickedData);
      }

      final croppedFile = await _cropImage(context, file);
      return Result.success((option: option, file: croppedFile));
      // ignore: avoid_catches_without_on_clauses
    } catch (e, _) {
      return Result.error(AppException(''));
    }
  }

  static Future<PickedData?> _showSourcePicker(
    BuildContext context, {
    List<PickerOption> availableOptions = PickerOption.values,
    ImageSourcePickerDialogData dialogData = const ImageSourcePickerDialogData(),
  }) async {
    final picker = ImagePicker();
    final result = await ImageSourcePickerDialog.show(
      context: context,
      availableOptions: availableOptions,
      data: dialogData,
    );

    if (result == null) return null;

    switch (result) {
      case PickerOption.deletePhoto:
        return (option: PickerOption.deletePhoto, file: null);
      case PickerOption.takePhoto:
      case PickerOption.selectPhoto:
        final source = result == PickerOption.takePhoto ? ImageSource.camera : ImageSource.gallery;
        final file = await picker.pickImage(
          source: source,
          requestFullMetadata: false,
          imageQuality: 90,
        );
        return (option: result, file: file != null ? File(file.path) : null);
    }
  }

  static Future<File?> _cropImage(BuildContext context, File imageFile) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          hidesNavigationBar: true,
          cancelButtonTitle: t.common.cancel_button,
          doneButtonTitle: t.common.done_button,
        ),
      ],
    );

    return croppedFile != null ? File(croppedFile.path) : null;
  }
}
