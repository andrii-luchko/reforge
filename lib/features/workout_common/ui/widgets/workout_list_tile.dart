import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/workout_common/ui/widgets/app_tags_list_view.dart';
import 'package:reforge/shared/app_cached_net_image.dart';
import 'package:reforge/shared/uikit/buttons/pressable_animation.dart';
import 'package:skeletonizer/skeletonizer.dart';

// ==========================================
// 1. Static Version (Compact, Fixed Size)
// ==========================================

class StaticWorkoutTile extends StatelessWidget {
  const StaticWorkoutTile({
    required this.title,
    required this.description,
    required this.imageUrl,
    this.tags,
    this.onTap,
    this.showTrailingIcon = true,
    this.icon,
    super.key,
  });

  final String title;
  final String description;
  final String? imageUrl;
  final List<String>? tags;
  final VoidCallback? onTap;
  final Widget? icon;
  final bool showTrailingIcon;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    final icon =
        this.icon ??
        Icon(
          Icons.chevron_right_rounded,
          color: appTheme.beige200,
          size: 32,
        );
    return _BaseWorkoutTileContainer(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _TileHeaderContent(
          title: title,
          description: description,
          imageUrl: imageUrl,
          tags: tags,

          imageSize: const Size(62, 62),
          isDescriptionExpanded: false,
          trailing: showTrailingIcon ? icon : null,
        ),
      ),
    );
  }
}

// ==========================================
// 2. Expandable Version (Animated, Large Image)
// ==========================================

class ExpandableWorkoutTile extends StatefulWidget {
  const ExpandableWorkoutTile({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.children,
    this.tags,
    this.onTap,
    this.initiallyExpanded = false,
    super.key,
  });

  final String title;
  final String description;
  final String? imageUrl;
  final List<String>? tags;
  final List<Widget> children;
  final VoidCallback? onTap;
  final bool initiallyExpanded;

  @override
  State<ExpandableWorkoutTile> createState() => _ExpandableWorkoutTileState();
}

class _ExpandableWorkoutTileState extends State<ExpandableWorkoutTile> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _iconTurns;
  late final Animation<double> _heightFactor;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _iconTurns = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _heightFactor = _controller.view;

    _isExpanded = widget.initiallyExpanded;
    if (_isExpanded) _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        unawaited(_controller.forward());
      } else {
        unawaited(_controller.reverse());
      }
    });
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final imageSize = (widget.tags == null || widget.tags!.isEmpty)
            ? Size.lerp(const Size(73, 85), const Size(62, 62), _controller.value)!
            : const Size(73, 85);

        return _BaseWorkoutTileContainer(
          onTap: _handleTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: _TileHeaderContent(
                  title: widget.title,
                  description: widget.description,
                  imageUrl: widget.imageUrl,
                  tags: widget.tags,
                  imageSize: imageSize,
                  isDescriptionExpanded: _isExpanded,
                  trailing: RotationTransition(
                    turns: _iconTurns,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: appTheme.beige200,
                      size: 32,
                    ),
                  ),
                ),
              ),
              _ExpandableBody(
                heightFactor: _heightFactor,
                children: widget.children,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ==========================================
// Shared Private Components
// ==========================================

class _BaseWorkoutTileContainer extends StatelessWidget {
  const _BaseWorkoutTileContainer({
    required this.child,
    this.onTap,
  });

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final borderRadius = BorderRadius.circular(20);

    return PressableAnimation(
      onTap: onTap,
      child: Material(
        color: appTheme.beige900,
        borderRadius: borderRadius,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: appTheme.radioButtonGradient,
            border: Border.all(color: appTheme.strokeCard),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _TileHeaderContent extends StatelessWidget {
  const _TileHeaderContent({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.tags,
    required this.imageSize,
    required this.isDescriptionExpanded,
    this.trailing,
  });

  final String title;
  final String description;
  final String? imageUrl;
  final List<String>? tags;
  final Size imageSize;
  final bool isDescriptionExpanded;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _WorkoutImage(
          imageUrl: imageUrl,
          size: imageSize,
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 4,
          child: _WorkoutDetails(
            title: title,
            description: description,
            tags: tags,
            isExpanded: isDescriptionExpanded,
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          Skeleton.ignore(child: trailing!),
        ],
      ],
    );
  }
}

class _WorkoutDetails extends StatelessWidget {
  const _WorkoutDetails({
    required this.title,
    required this.description,
    required this.isExpanded,
    this.tags,
  });

  final String title;
  final String description;
  final List<String>? tags;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final descriptionStyle = subheadH6Regular.copyWith(color: appTheme.beige600);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: subheadH3Medium.copyWith(color: appTheme.beige100),
        ),
        const SizedBox(height: 7),
        AnimatedCrossFade(
          firstChild: Text(
            description,
            style: descriptionStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          secondChild: Text(
            description,
            style: descriptionStyle,
          ),
          crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
          alignment: Alignment.topLeft,
          firstCurve: Curves.easeOut,
          secondCurve: Curves.easeOut,
        ),
        if (tags != null && tags!.isNotEmpty) ...[
          const SizedBox(height: 7),
          AppTagsListView(tags: tags!),
        ],
      ],
    );
  }
}

class _WorkoutImage extends StatelessWidget {
  const _WorkoutImage({required this.imageUrl, required this.size});

  final String? imageUrl;
  final Size size;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && !imageUrl!.contains('thumb.url');
    final appTheme = context.appTheme;
    final borderRadius = BorderRadius.circular(20);

    return Skeleton.leaf(
      child: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: appTheme.beige1000.withValues(alpha: 0.2),
          border: GradientBoxBorder(
            gradient: LinearGradient(
              begin: .topLeft,
              end: .bottomRight,
              colors: [
                const Color(0xFFDDD9D1),
                const Color(0xFFDDD9D1).withValues(alpha: 0),
              ],
            ),
          ),
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: hasImage ? AppCachedNetImage(imageUrl: imageUrl!) : const AppImageErrorWidget(),
        ),
      ),
    );
  }
}

class _ExpandableBody extends StatelessWidget {
  const _ExpandableBody({
    required this.heightFactor,
    required this.children,
  });

  final Animation<double> heightFactor;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Align(
        alignment: Alignment.topCenter,
        heightFactor: heightFactor.value,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }
}
