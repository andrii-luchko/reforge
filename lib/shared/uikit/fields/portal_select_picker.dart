import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/shared/uikit/fields/app_text_field.dart';
import 'package:reforge/shared/uikit/selector_suffix_icon.dart';

typedef PortalContentBuilder = Widget Function(BuildContext context, VoidCallback close);

class PortalSelectField extends StatefulWidget {
  const PortalSelectField({
    required this.contentBuilder,
    this.controller,
    this.hintText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.portalAnchor = Alignment.topCenter,
    this.targetAnchor = Alignment.bottomCenter,
    super.key,
  });

  final TextEditingController? controller;

  final PortalContentBuilder contentBuilder;

  final String? hintText;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  final Alignment portalAnchor;
  final Alignment targetAnchor;

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
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  Future<void> _toggleDropdown() async {
    if (_isOpen) {
      await _close();
    } else {
      setState(() => _isOpen = true);
      await _controller.forward();
    }
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
        heightFactor: 10,
      ),
      portalFollower: _PortalContentWrapper(
        animation: _expandAnimation,
        child: widget.contentBuilder(context, _close),
      ),
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: AbsorbPointer(
          child: AppTextField(
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
