import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/shared/uikit/blur_container.dart';
import 'package:reforge/shared/uikit/glass_container.dart';

class StaggeredSummaryCard extends StatefulWidget {
  const StaggeredSummaryCard({
    required this.items,
    this.dividerHeight = 24,
    super.key,
  });

  final List<Widget> items;
  final double dividerHeight;

  @override
  State<StaggeredSummaryCard> createState() => _StaggeredSummaryCardState();
}

class _StaggeredSummaryCardState extends State<StaggeredSummaryCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return BlurContainer(
      sigmaX: 20,
      sigmaY: 20,
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _buildAnimatedItems(appTheme),
        ),
      ),
    );
  }

  List<Widget> _buildAnimatedItems(AppTheme appTheme) {
    final animatedList = <Widget>[];

    for (var i = 0; i < widget.items.length; i++) {
      animatedList.add(
        AnimatedStaggeredRow(
          index: i,
          controller: _controller,
          child: widget.items[i],
        ),
      );
      if (i != widget.items.length - 1) {
        animatedList.add(
          AnimatedStaggeredRow(
            index: i,
            controller: _controller,
            child: Divider(
              height: widget.dividerHeight,
              color: appTheme.beige700,
            ),
          ),
        );
      }
    }
    return animatedList;
  }
}

class AnimatedStaggeredRow extends StatelessWidget {
  const AnimatedStaggeredRow({
    required this.index,
    required this.child,
    required this.controller,
    super.key,
  });

  final int index;
  final Widget child;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final start = (index * 0.1).clamp(0.0, 1.0);
    final end = (start + 0.4).clamp(0.0, 1.0);

    final opacityAnimation = CurvedAnimation(
      parent: controller,
      curve: Interval(start, end, curve: Curves.easeIn),
    );

    final slideAnimation =
        Tween<Offset>(
          begin: const Offset(0.05, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(start, end, curve: Curves.easeOutBack),
          ),
        );

    return FadeTransition(
      opacity: opacityAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: child,
      ),
    );
  }
}

class SummaryRowWidget extends StatelessWidget {
  const SummaryRowWidget({required this.number, required this.title, required this.tag, super.key});

  final int number;
  final String title;
  final Widget tag;
  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Row(
      children: [
        Text('0$number/', style: subheadH3Medium.copyWith(color: appTheme.orange500)),
        const SizedBox(width: 7),
        Text(title, style: subheadH3Medium.copyWith(color: appTheme.beige100)),
        const Spacer(),
        tag,
      ],
    );
  }
}
