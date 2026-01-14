import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/training_session/ui/widgets/app_tags_list_view.dart';
import 'package:skeletonizer/skeletonizer.dart';

class WorkoutListTile extends StatelessWidget {
  const WorkoutListTile({
    required this.description,
    required this.imageUrl,
    required this.tags,
    required this.title,
    this.onTap,
    super.key,
  });

  final String title;
  final String description;
  final String? imageUrl;
  final List<String> tags;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final borderRadius = BorderRadius.circular(20);
    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onTap,
        splashFactory: InkSparkle.splashFactory,
        splashColor: appTheme.beige100.withValues(alpha: 0.1),
        highlightColor: appTheme.beige100.withValues(alpha: 0.01),
        borderRadius: borderRadius,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: appTheme.radioButtonGradient,

            border: Border.all(
              color: appTheme.strokeCard,
            ),
          ),
          child: Row(
            children: [
              _WorkoutImage(imageUrl: imageUrl),
              const SizedBox(width: 8),
              Expanded(
                flex: 4,
                child: _WorkoutDetails(
                  title: title,
                  description: description,

                  tags: tags,
                ),
              ),

              Skeleton.ignore(
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: appTheme.beige200,
                  size: 32,
                ),
              ),
            ],
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
    required this.tags,
  });

  final String title;
  final String description;
  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          title,
          style: subheadH3Medium.copyWith(color: appTheme.beige100),
        ),
        const SizedBox(height: 7),
        Text(
          description,
          style: subheadH6Regular.copyWith(color: appTheme.beige600),
          maxLines: 1,
          overflow: .ellipsis,
        ),
        const SizedBox(height: 7),
        AppTagsListView(tags: tags),
      ],
    );
  }
}

class _WorkoutImage extends StatelessWidget {
  const _WorkoutImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null;

    final appTheme = context.appTheme;
    final borderRadius = BorderRadius.circular(20);

    final errorWidget = ColoredBox(
      color: appTheme.beige200,
      child: Icon(
        Icons.image_not_supported_rounded,
        color: appTheme.beige600,
      ),
    );
    return Skeleton.leaf(
      child: Container(
        width: 73,
        height: 85,
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
          child: hasImage
              ? CachedNetworkImage(
                  imageUrl: imageUrl!,
                  fit: BoxFit.cover,
                  progressIndicatorBuilder: (context, url, progress) => ColoredBox(
                    color: appTheme.beige200,
                    child: Center(
                      child: CircularProgressIndicator.adaptive(
                        value: progress.progress,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          appTheme.beige600,
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => errorWidget,
                )
              : errorWidget,
        ),
      ),
    );
  }
}
