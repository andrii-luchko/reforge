import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/core/photo/enum/picker_option.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/dialogs/default_dialog_header.dart';

typedef PickedData = ({PickerOption option, File? file});

class ImagePickerService {
  static Future<PickedData?> pickAndCrop(BuildContext context) async {
    final pickedData = await _showSourcePicker(context);
    if (pickedData == null) return null;

    if (!context.mounted) return pickedData;

    final option = pickedData.option;
    final file = pickedData.file;

    if (file == null || option == PickerOption.deletePhoto) {
      return pickedData;
    }

    final croppedFile = await _cropImage(context, file);
    return (option: option, file: croppedFile);
  }

  static Future<PickedData?> _showSourcePicker(BuildContext context) async {
    final picker = ImagePicker();
    final result = await showModalBottomSheet<PickerOption>(
      context: context,
      backgroundColor: context.appTheme.beige900,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const DefaultDialogHeader(title: 'Edit profile picture'),
              const SizedBox(height: 12),
              _buildPickerItem(
                context,
                title: 'Take photo',
                iconPath: Assets.images.icons.camera,
                onTap: () => Navigator.pop(ctx, PickerOption.takePhoto),
              ),
              const SizedBox(height: 12),
              _buildPickerItem(
                context,
                title: 'Choose photo',
                iconPath: Assets.images.icons.gallery,
                onTap: () => Navigator.pop(ctx, PickerOption.selectPhoto),
              ),
              const SizedBox(height: 12),
              _buildPickerItem(
                context,
                title: 'Delete photo',
                iconPath: Assets.images.icons.trash,
                isDestructive: true,
                onTap: () => Navigator.pop(ctx, PickerOption.deletePhoto),
              ),
            ],
          ),
        ),
      ),
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

  // ignore: avoid_returning_widgets
  static Widget _buildPickerItem(
    BuildContext context, {
    required String title,
    required String iconPath,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? context.appTheme.red400 : context.appTheme.beige100;

    return Container(
      padding: const .all(16),
      decoration: BoxDecoration(
        border: .all(color: context.appTheme.strokeCard),
        borderRadius: .circular(20),
      ),
      child: Row(
        spacing: 10,
        children: [
          SvgPicture.asset(
            iconPath,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
          Text(
            title,
            style: subheadH3Medium.copyWith(color: color),
          ),
        ],
      ),
    );
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
