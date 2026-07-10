import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/core/photo/enum/picker_option.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/shared/dialogs/app_dialog.dart';
import 'package:reforge/shared/dialogs/default_dialog_header.dart';
import 'package:reforge/shared/uikit/buttons/pressable_animation.dart';

class ImageSourcePickerDialogData {
  const ImageSourcePickerDialogData({
    this.title = 'Select image',
    this.takePhotoTitle = 'Take photo',
    this.selectPhotoTitle = 'Choose photo',
    this.deletePhotoTitle = 'Delete photo',
  });

  final String title;
  final String takePhotoTitle;
  final String selectPhotoTitle;
  final String deletePhotoTitle;

  String titleFor(PickerOption option) {
    return switch (option) {
      PickerOption.takePhoto => takePhotoTitle,
      PickerOption.selectPhoto => selectPhotoTitle,
      PickerOption.deletePhoto => deletePhotoTitle,
    };
  }
}

class ImageSourcePickerDialog extends StatelessWidget {
  const ImageSourcePickerDialog({
    required this.availableOptions,
    this.data = const ImageSourcePickerDialogData(),
    super.key,
  });

  final List<PickerOption> availableOptions;
  final ImageSourcePickerDialogData data;

  static Future<PickerOption?> show({
    required BuildContext context,
    List<PickerOption> availableOptions = PickerOption.values,
    ImageSourcePickerDialogData data = const ImageSourcePickerDialogData(),
  }) {
    return AppDialog.show<PickerOption>(
      context,
      child: ImageSourcePickerDialog(
        availableOptions: availableOptions,
        data: data,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final options = availableOptions.toSet().toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DefaultDialogHeader(title: data.title),
          const SizedBox(height: 12),
          for (final option in options) ...[
            _ImageSourcePickerOption(
              option: option,
              title: data.titleFor(option),
              onTap: () => Navigator.of(context).pop(option),
            ),
            if (option != options.last) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _ImageSourcePickerOption extends StatelessWidget {
  const _ImageSourcePickerOption({
    required this.option,
    required this.title,
    required this.onTap,
  });

  final PickerOption option;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDestructive = option == PickerOption.deletePhoto;
    final color = isDestructive ? context.appTheme.red400 : context.appTheme.beige100;

    return PressableAnimation(
      scaleAmount: 0.98,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: context.appTheme.strokeCard),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          spacing: 10,
          children: [
            SvgPicture.asset(
              _iconFor(option),
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            Text(
              title,
              style: subheadH3Medium.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }

  String _iconFor(PickerOption option) {
    return switch (option) {
      PickerOption.takePhoto => Assets.images.icons.cameraAlt,
      PickerOption.selectPhoto => Assets.images.icons.gallery,
      PickerOption.deletePhoto => Assets.images.icons.trash,
    };
  }
}
