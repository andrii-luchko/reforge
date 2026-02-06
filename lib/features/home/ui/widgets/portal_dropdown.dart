import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:reforge/app/theme/app_theme.dart';

typedef PortalContentBuilder = Widget Function(BuildContext context, VoidCallback close);

// ignore: avoid_positional_boolean_parameters
typedef PortalTriggerBuilder = Widget Function(BuildContext context, bool isOpen);

class PortalDropdown extends StatefulWidget {
  const PortalDropdown({
    required this.triggerBuilder,
    required this.contentBuilder,
    this.portalAnchor = Alignment.topCenter,
    this.targetAnchor = Alignment.bottomCenter,
    this.contentPadding = EdgeInsets.zero,
    this.portalFollowerWidth,
    super.key,
  });

  final PortalTriggerBuilder triggerBuilder;
  final PortalContentBuilder contentBuilder;

  final Alignment portalAnchor;
  final Alignment targetAnchor;

  final EdgeInsets contentPadding;
  final double? portalFollowerWidth;

  @override
  State<PortalDropdown> createState() => _PortalDropdownState();
}

class _PortalDropdownState extends State<PortalDropdown> with SingleTickerProviderStateMixin {
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
    if (mounted) {
      setState(() => _isOpen = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PortalTarget(
      visible: _isOpen,
      anchor: Aligned(
        follower: widget.portalAnchor,
        target: widget.targetAnchor,

        widthFactor: widget.portalFollowerWidth ?? 1.0,
        portal: Alignment.bottomCenter,
      ),
      portalFollower: _PortalContentWrapper(
        animation: _expandAnimation,
        contentPadding: widget.contentPadding,
        child: widget.contentBuilder(context, _close),
      ),
      child: GestureDetector(
        onTap: _toggleDropdown,
        behavior: HitTestBehavior.opaque,
        child: widget.triggerBuilder(context, _isOpen),
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
    required this.contentPadding,
    required this.animation,
    required this.child,
  });

  final EdgeInsets contentPadding;
  final Animation<double> animation;
  final Widget child;
  static const _borderRadius = 12.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .all(8),
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
