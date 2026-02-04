import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/shared/uikit/fields/app_text_field.dart';
import 'package:reforge/shared/uikit/selector_suffix_icon.dart';

class PortalSelectController {
  _PortalSelectFieldState? _state;

  // ignore: use_setters_to_change_properties
  void _attach(_PortalSelectFieldState state) {
    _state = state;
  }

  void _detach() {
    _state = null;
  }

  Future<void> open() async => _state?.open();
  Future<void> close() async => _state?.close();
  Future<void> toggle() async => _state?.toggle();

  bool get isOpen => _state?._isOpen ?? false;
}

typedef PortalContentBuilder = Widget Function(BuildContext context, VoidCallback close);

class PortalSelectField extends StatefulWidget {
  const PortalSelectField({
    required this.contentBuilder,
    this.controller,
    this.portalController,
    this.onTap,
    this.hintText,
    this.errorText,
    this.initialText,
    this.prefixIcon,
    this.suffixIcon,
    this.portalAnchor = Alignment.topCenter,
    this.targetAnchor = Alignment.bottomCenter,
    this.heightFactor = 10,
    super.key,
  }) : assert(
         !(controller != null && initialText != null),
         'You cannot pass both controller and initialText at the same time. '
         'Use one or the other to avoid data conflicts.',
       );

  final TextEditingController? controller;
  final PortalSelectController? portalController;
  final VoidCallback? onTap;
  final PortalContentBuilder contentBuilder;

  final String? initialText;
  final String? hintText;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  final Alignment portalAnchor;
  final Alignment targetAnchor;

  final double heightFactor;

  @override
  State<PortalSelectField> createState() => _PortalSelectFieldState();
}

class _PortalSelectFieldState extends State<PortalSelectField> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;

  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    widget.portalController?._attach(this);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didUpdateWidget(covariant PortalSelectField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.portalController != widget.portalController) {
      oldWidget.portalController?._detach();
      widget.portalController?._attach(this);
    }
  }

  Future<void> toggle() async {
    if (_isOpen) {
      await close();
    } else {
      await open();
    }
  }

  Future<void> open() async {
    if (_isOpen) return;
    setState(() => _isOpen = true);
    await _controller.forward();
  }

  Future<void> close() async {
    if (!_isOpen) return;
    await _controller.reverse();
    setState(() => _isOpen = false);
  }

  Future<void> _close() async {
    await _controller.reverse();
    setState(() => _isOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    return PortalTarget(
      visible: _isOpen,
      anchor: Aligned(
        follower: widget.portalAnchor,
        target: widget.targetAnchor,
        portal: Alignment.centerRight,
        heightFactor: widget.heightFactor,
      ),
      portalFollower: _PortalContentWrapper(
        animation: _expandAnimation,
        child: widget.contentBuilder(context, _close),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          widget.onTap?.call();

          unawaited(toggle());
        },
        child: AbsorbPointer(
          child: AppTextField(
            initialValue: widget.initialText,
            controller: widget.controller,
            hintText: widget.hintText,
            errorText: widget.errorText,
            prefixIcon: widget.prefixIcon,

            suffixIcon: widget.suffixIcon ?? SelectorSuffixIcon(isOpen: _isOpen),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.portalController?._detach();
    _controller.dispose();
    super.dispose();
  }
}

class _PortalContentWrapper extends StatelessWidget {
  const _PortalContentWrapper({
    required this.animation,
    required this.child,
  });

  final Animation<double> animation;
  final Widget child;

  static const _borderRadius = 12.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 18, right: 18),
      child: FadeTransition(
        opacity: animation,
        child: SizeTransition(
          sizeFactor: animation,
          axisAlignment: -1,
          child: Material(
            borderRadius: BorderRadius.circular(_borderRadius),
            elevation: 8,
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: context.appTheme.beige900,
                borderRadius: BorderRadius.circular(_borderRadius),
                border: Border.all(color: context.appTheme.strokeCard),
              ),

              child: ClipRRect(
                borderRadius: BorderRadius.circular(_borderRadius),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
