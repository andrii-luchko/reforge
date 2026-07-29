import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/features/guides/controller/guide_cubit.dart';
import 'package:showcaseview/showcaseview.dart';

class GuideTarget extends StatelessWidget {
  const GuideTarget({
    required this.anchor,
    required this.scope,
    required this.guideCubit,
    required this.tooltip,
    required this.child,
    this.targetPadding = const EdgeInsets.all(6),
    this.targetBorderRadius = const BorderRadius.all(Radius.circular(16)),
    this.disableBarrierInteraction = true,
    super.key,
  });

  final GlobalKey anchor;
  final String scope;
  final GuideCubit guideCubit;
  final Widget tooltip;
  final Widget child;
  final EdgeInsets targetPadding;
  final BorderRadius targetBorderRadius;
  final bool disableBarrierInteraction;

  @override
  Widget build(BuildContext context) {
    return Showcase.withWidget(
      key: anchor,
      scope: scope,
      overlayColor: context.appTheme.beige1000,
      overlayOpacity: 0.97,
      targetPadding: targetPadding,
      targetBorderRadius: targetBorderRadius,
      disableMovingAnimation: true,
      disableBarrierInteraction: disableBarrierInteraction,
      disableDefaultTargetGestures: true,
      container: BlocProvider.value(
        value: guideCubit,
        child: tooltip,
      ),
      child: child,
    );
  }
}
