import 'package:flutter/material.dart';
import 'package:reforge/shared/dialogs/default_dialog_header.dart';
import 'package:reforge/shared/uikit/buttons/secondary_button.dart';

class EditDialogTemplate<T> extends StatefulWidget {
  const EditDialogTemplate({
    required this.title,
    required this.buttonLabel,
    required this.initialValue,

    required this.contentBuilder,
    this.onConfirm,
    super.key,
  });

  final String title;
  final String buttonLabel;
  final T initialValue;
  final void Function(T)? onConfirm;

  final Widget Function(BuildContext context, ValueNotifier<T> controller) contentBuilder;

  @override
  State<EditDialogTemplate<T>> createState() => _EditDialogTemplateState<T>();
}

class _EditDialogTemplateState<T> extends State<EditDialogTemplate<T>> {
  late final ValueNotifier<T> _controller;

  @override
  void initState() {
    super.initState();
    _controller = ValueNotifier(widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: .min,
        mainAxisAlignment: .center,
        spacing: 32,
        children: [
          DefaultDialogHeader(title: widget.title),

          widget.contentBuilder(context, _controller),

          SecondaryButton(
            text: widget.buttonLabel,
            onPressed: () {
              widget.onConfirm?.call(_controller.value);
              Navigator.pop(context, _controller.value);
            },
          ),
        ],
      ),
    );
  }
}
