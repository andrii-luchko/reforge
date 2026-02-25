import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/home/domain/enum/stats_period.dart';
import 'package:reforge/features/home/ui/widgets/portal_dropdown.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/base_glass_container.dart';
import 'package:reforge/shared/uikit/blur_container.dart';
import 'package:reforge/shared/uikit/selector_suffix_icon.dart';

class StatsPeriodSelector extends StatelessWidget {
  const StatsPeriodSelector({
    required this.selectedPeriod,
    required this.onChanged,
    super.key,
  });

  final StatsPeriod selectedPeriod;
  final ValueChanged<StatsPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return PortalDropdown(
      targetAnchor: Alignment.center,
      contentPadding: const EdgeInsets.only(top: 24),

      triggerBuilder: _buildTrigger,

      contentBuilder: _buildDropdownContent,
    );
  }

  Widget _buildTrigger(BuildContext context, bool isOpened) {
    final appTheme = context.appTheme;

    return BlurContainer(
      child: BaseGlassContainer(
        glassEffectGradientAlignmentBegin: Alignment.topLeft,
        glassEffectGradientAlignmentEnd: Alignment.bottomRight,
        borderGradientStops: const [0.0, 0.1, 0.3, 0.9, 1.0],
        borderGradientColors: [
          Colors.transparent,
          appTheme.beige100,
          Colors.transparent,
          Colors.transparent,
          appTheme.beige100,
        ],
        borderColor: appTheme.beige100.withValues(alpha: 0.1),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 180),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 4, top: 8, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedPeriod.label(context.t),
                  style: subheadH5Medium.copyWith(color: appTheme.beige700),
                ),

                SelectorSuffixIcon(isOpen: isOpened),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownContent(BuildContext context, VoidCallback onClose) {
    final appTheme = context.appTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: StatsPeriod.values.map((period) {
        final isSelected = selectedPeriod == period;

        return GestureDetector(
          onTap: () {
            onChanged(period);
            onClose();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    period.label(context.t),
                    style: subheadH5Medium.copyWith(
                      color: isSelected ? appTheme.beige100 : appTheme.beige600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected) Icon(Icons.check, size: 16, color: appTheme.beige100),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
