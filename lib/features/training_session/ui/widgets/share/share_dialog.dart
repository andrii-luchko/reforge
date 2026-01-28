import 'dart:async';
import 'package:flutter/material.dart';
import 'package:reforge/app/di/service_injector.dart' as di;
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/utils/toasts/show_toast.dart';
import 'package:reforge/features/training_session/controllers/share/share_controller.dart';
import 'package:reforge/shared/dialogs/app_dialog.dart';
import 'package:reforge/shared/dialogs/default_dialog_header.dart';
import 'package:reforge/shared/uikit/buttons/primary_button.dart';
import 'package:reforge/shared/uikit/buttons/secondary_button.dart';
import 'package:reforge/shared/uikit/buttons/thirty_button.dart';
import 'package:reforge/shared/uikit/toasts/app_simple_toast.dart';
import 'package:toastification/toastification.dart';

class ShareButton extends StatelessWidget {
  const ShareButton({
    required this.shareContent,
    super.key,
  });

  final Widget shareContent;

  @override
  Widget build(BuildContext context) {
    return SecondaryButton(
      text: 'Share',
      onPressed: () async {
        final controller = di.getIt<ShareController>();

        await AppDialog.show<void>(
          context,
          child: _ShareDialogContent(
            controller: controller,
            shareContent: shareContent,
          ),
        );
      },
    );
  }
}

class _ShareDialogContent extends StatefulWidget {
  const _ShareDialogContent({
    required this.controller,
    required this.shareContent,
  });

  final Widget shareContent;
  final ShareController controller;

  @override
  State<_ShareDialogContent> createState() => _ShareDialogContentState();
}

class _ShareDialogContentState extends State<_ShareDialogContent> {
  final GlobalKey _contentKey = GlobalKey();
  bool _isLoading = false;

  Future<void> _performAction(Future<void> Function() action) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 50));

    try {
      await action();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const DefaultDialogHeader(
            title: 'Share Your Progress',
            textFlex: 5,
          ),
          const SizedBox(height: 16),

          RepaintBoundary(
            key: _contentKey,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              color: context.appTheme.beige900,
              child: widget.shareContent,
            ),
          ),

          const SizedBox(height: 16),

          AbsorbPointer(
            absorbing: _isLoading,
            child: Column(
              children: [
                ThirtyButton(
                  text: 'Instagram',
                  onPressed: () => _performAction(
                    () => widget.controller.captureAndShare(_contentKey),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  spacing: 16,
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        text: 'Share',
                        onPressed: () => _performAction(
                          () => widget.controller.captureAndShare(_contentKey),
                        ),
                      ),
                    ),
                    Expanded(
                      child: PrimaryButton(
                        text: 'Save',
                        onPressed: () => _performAction(() async {
                          final saved = await widget.controller.captureAndSaveToGallery(_contentKey);

                          if (saved) {
                            toastification.showCustomToast(
                              (context, item) {
                                return const Center(child: AppSimpleToast(text: 'Saved'));
                              },
                            );
                          }
                        }),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
