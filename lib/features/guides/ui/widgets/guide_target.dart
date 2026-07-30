import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/features/guides/controller/guide_cubit.dart';
import 'package:showcaseview/showcaseview.dart';

class GuideTarget extends StatelessWidget {
  const GuideTarget({
    required this.anchor,
    required this.scope,
    required this.tooltip,
    required this.child,
    this.targetPadding = const EdgeInsets.all(6),
    this.targetBorderRadius = const BorderRadius.all(Radius.circular(16)),
    this.enableAutoScroll = false,
    this.scrollAlignment = 0.5,
    super.key,
  });

  final GlobalKey anchor;
  final String scope;
  final Widget tooltip;
  final Widget child;
  final EdgeInsets targetPadding;
  final BorderRadius targetBorderRadius;
  final bool? enableAutoScroll;
  final double scrollAlignment;

  @override
  Widget build(BuildContext context) {
    final guideCubit = context.read<GuideCubit>();

    return Showcase.withWidget(
      scrollLoadingWidget: const SizedBox.shrink(),
      key: anchor,
      enableAutoScroll: enableAutoScroll,
      scrollAlignment: scrollAlignment,
      scope: scope,
      overlayColor: context.appTheme.beige1000,
      overlayOpacity: 0.97,
      targetPadding: targetPadding,
      targetBorderRadius: targetBorderRadius,
      disableMovingAnimation: true,
      disableBarrierInteraction: true,
      disableDefaultTargetGestures: true,
      container: BlocProvider.value(
        value: guideCubit,
        child: tooltip,
      ),
      child: child,
    );
  }
}
