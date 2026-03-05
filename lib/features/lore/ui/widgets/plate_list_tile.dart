import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/toasts/show_toast.dart';
import 'package:reforge/features/lore/domain/entity/plates_entity.dart';
import 'package:reforge/features/lore/ui/widgets/lore_cad_empty.dart';
import 'package:reforge/features/lore/ui/widgets/lore_card.dart';
import 'package:reforge/features/lore/ui/widgets/lore_step.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/app_cached_net_image.dart';
import 'package:toastification/toastification.dart';

class PlateListTile extends StatefulWidget {
  const PlateListTile({
    required this.model,
    this.loadingDetailId,
    this.onTap,
    super.key,
  });

  final PlatesEntity model;
  final int? loadingDetailId;
  final VoidCallback? onTap;

  @override
  State<PlateListTile> createState() => _PlateListTileState();
}

class _PlateListTileState extends State<PlateListTile> {
  bool _isExpanded = false;

  static const _fillGradient = LinearGradient(
    begin: Alignment(-0.53, -1),
    end: Alignment(0.96, 1),
    colors: [Color(0x009D3C10), Color(0x4D9D3C10)],
    stops: [0.6, 1.0],
  );

  static const _activeStrokeColor = Color(0x779D3D10);
  static const _defaultStrokeColor = Color(0x66ECE7DC);

  static const _activeBorderGradient = LinearGradient(
    begin: Alignment(0.47, 0.82),
    end: Alignment(-0.96, -0.82),
    colors: [Color(0x009D3C10), Color(0xFF9D3C10)],
  );

  static const _defaultBorderGradient = LinearGradient(
    begin: Alignment(0.47, 0.82),
    end: Alignment(-0.96, -0.82),
    colors: [Color(0x00ECE7DC), Color(0xFFECE7DC)],
  );

  void _handleTap() {
    if (!widget.model.isLocked && widget.model.loreBody == null) {
      widget.onTap?.call();
    }
    setState(() => _isExpanded = !_isExpanded);
  }

  void _showMessage() {
    toastification.showSimpleToast(
      t.lore.lockedPlateToast(name: widget.model.name, level: widget.model.unlockLevel),
      alignment: .center,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = widget.model.isLocked;
    final lockedStroke = context.appTheme.strokeCard;
    final lockedBorder = context.appTheme.styleCard;
    final lockedTextColor = context.appTheme.beige700;
    final activeTextColor = context.appTheme.beige100;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: _isExpanded ? 1.0 : 0.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,

      child: PlateDetails(
        model: widget.model,
        isLoading: widget.loadingDetailId == widget.model.id,
      ),
      builder: (context, value, cachedChild) {
        final currentStroke = isLocked ? lockedStroke : Color.lerp(_defaultStrokeColor, _activeStrokeColor, value);

        final currentBorder = isLocked
            ? lockedBorder
            : Gradient.lerp(_defaultBorderGradient, _activeBorderGradient, value);

        return Column(
          children: [
            LoreCard(
              fillGradient: _fillGradient,
              strokeColor: currentStroke,
              borderGradient: currentBorder,
              onTap: isLocked ? _showMessage : _handleTap,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.model.name,
                      style: subheadH3Medium.copyWith(
                        color: isLocked ? lockedTextColor : activeTextColor,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Transform.rotate(
                      angle: value * 0.25 * 6.28318,
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 32,
                        color: isLocked ? lockedTextColor : activeTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: value,
                child: cachedChild,
              ),
            ),
          ],
        );
      },
    );
  }
}

class PlateDetails extends StatelessWidget {
  const PlateDetails({
    required this.model,
    this.isLoading = false,
    super.key,
  });

  final PlatesEntity model;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.appTheme.beige900,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: context.appTheme.orange600),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PlateImage(imageUrl: model.imageUrl),
                const SizedBox(height: 16),
                Text(
                  model.title.toUpperCase(),
                  style: subheadH5Medium.copyWith(color: context.appTheme.beige700),
                ),
                const SizedBox(height: 16),
                if (isLoading && model.loreBody == null)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (model.loreSteps.isEmpty)
                  const LoreCardEmpty()
                else
                  ...model.loreSteps.mapIndexed(
                    (i, v) => LoreStep(
                      isLast: i == model.loreSteps.length - 1,
                      stepText: v,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PlateImage extends StatelessWidget {
  const PlateImage({super.key, this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final imageUrl = this.imageUrl;
    final hasImage = imageUrl != null && !imageUrl.contains('thumb.url');

    final borderRadius = BorderRadius.circular(20);
    return AspectRatio(
      aspectRatio: 324 / 116,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: appTheme.beige900,
          border: Border.all(color: appTheme.strokeCard),
        ),

        child: ClipRRect(
          borderRadius: borderRadius,
          child: hasImage ? AppCachedNetImage(imageUrl: imageUrl) : const AppImageErrorWidget(),
        ),
      ),
    );
  }
}
