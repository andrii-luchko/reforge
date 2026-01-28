import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/training_session/ui/widgets/app_tags_list_view.dart';
import 'package:reforge/shared/app_cached_net_image.dart';
import 'package:skeletonizer/skeletonizer.dart';

class WorkoutListTile extends StatefulWidget {
  const WorkoutListTile({
    required this.title,
    required this.description,
    required this.imageUrl,
    this.tags,
    this.children,
    this.onTap,
    this.initiallyExpanded = false,
    this.showTrailingIcon = true,
    super.key,
  });

  final String title;
  final String description;
  final String? imageUrl;
  final List<String>? tags;
  final List<Widget>? children;
  final VoidCallback? onTap;
  final bool initiallyExpanded;
  final bool showTrailingIcon;

  @override
  State<WorkoutListTile> createState() => _WorkoutListTileState();
}

class _WorkoutListTileState extends State<WorkoutListTile> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _iconTurns;
  late final Animation<double> _heightFactor;

  bool _isExpanded = false;
  bool get _hasChildren => widget.children != null && widget.children!.isNotEmpty;

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
    if (_hasChildren) {
      setState(() {
        _isExpanded = !_isExpanded;
        if (_isExpanded) {
          unawaited(_controller.forward());
        } else {
          unawaited(_controller.reverse());
        }
      });

      widget.onTap?.call();
    } else {
      widget.onTap?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final borderRadius = BorderRadius.circular(20);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Material(
          color: appTheme.beige900,
          borderRadius: borderRadius,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: appTheme.radioButtonGradient,
              border: Border.all(color: appTheme.strokeCard),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TileHeader(
                  title: widget.title,
                  description: widget.description,
                  imageUrl: widget.imageUrl,
                  tags: widget.tags,
                  onTap: _handleTap,
                  borderRadius: borderRadius,
                  isExpanded: _isExpanded,
                  animationValue: _controller.value,

                  trailing: _buildTrailingIcon(appTheme),
                ),

                if (_hasChildren)
                  _ExpandableBody(
                    heightFactor: _heightFactor,
                    children: widget.children!,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget? _buildTrailingIcon(AppTheme appTheme) {
    if (_hasChildren) {
      return RotationTransition(
        turns: _iconTurns,
        child: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: appTheme.beige200,
          size: 32,
        ),
      );
    }

    if (widget.onTap != null && widget.showTrailingIcon) {
      return Icon(
        Icons.chevron_right_rounded,
        color: appTheme.beige200,
        size: 32,
      );
    }

    return const SizedBox(
      height: 32,
      width: 32,
    );
  }
}

class _TileHeader extends StatelessWidget {
  const _TileHeader({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.tags,
    required this.onTap,
    required this.borderRadius,
    required this.isExpanded,
    required this.animationValue,
    this.trailing,
  });

  final String title;
  final String description;
  final String? imageUrl;
  final List<String>? tags;
  final VoidCallback onTap;
  final BorderRadius borderRadius;
  final bool isExpanded;
  final double animationValue;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final noTags = tags == null || tags!.isEmpty;

    final currentImageSize = noTags
        ? Size.lerp(const Size(73, 85), const Size(62, 62), animationValue)!
        : const Size(73, 85);

    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      splashColor: appTheme.beige100.withValues(alpha: 0.1),
      highlightColor: appTheme.beige100.withValues(alpha: 0.01),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _WorkoutImage(
              imageUrl: imageUrl,
              size: currentImageSize,
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 4,
              child: _WorkoutDetails(
                title: title,
                description: description,
                tags: tags,
                isExpanded: isExpanded,
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              Skeleton.ignore(child: trailing!),
            ],
          ],
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
        clipBehavior: Clip.hardEdge,
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
