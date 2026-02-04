import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/shared/dialogs/default_dialog_header.dart';

class ImagePickerService {
  static Future<File?> pickAndCrop(BuildContext context) async {
    final originalFile = await _showSourcePicker(context);
    if (originalFile == null) return null;

    if (!context.mounted) return originalFile;

    return _cropImage(context, originalFile);
  }

  static Future<File?> _showSourcePicker(BuildContext context) async {
    final picker = ImagePicker();
    final result = await showModalBottomSheet<dynamic>(
      context: context,
      backgroundColor: context.appTheme.beige900,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
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
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              _buildPickerItem(
                context,
                title: 'Choose photo',
                iconPath: Assets.images.icons.gallery,
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              const SizedBox(height: 12),
              _buildPickerItem(
                context,
                title: 'Delete photo',
                iconPath: Assets.images.icons.trash,
                isDestructive: true,
                onTap: () => Navigator.pop(ctx, 'delete'),
              ),
            ],
          ),
        ),
      ),
    );

    if (result is ImageSource) {
      final file = await picker.pickImage(source: result);
      return file != null ? File(file.path) : null;
    } else if (result == 'delete') {
      return null;
    }

    return null;
  }

  static Widget _buildPickerItem(
    BuildContext context, {
    required String title,
    required String iconPath,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? context.appTheme.red400 : context.appTheme.beige100;

    return ListTile(
      onTap: onTap,
      title: Text(
        title,
        style: subheadH5Medium.copyWith(color: color),
      ),
      trailing: SvgPicture.asset(
        iconPath,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
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
          cancelButtonTitle: 'Cancel',
          doneButtonTitle: 'Done',
        ),
      ],
    );

    return croppedFile != null ? File(croppedFile.path) : null;
  }
}
