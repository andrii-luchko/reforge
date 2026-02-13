import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/shared/app_switch.dart';

class NotificationSwitcher extends StatelessWidget {
  const NotificationSwitcher({
    required this.title,
    required this.value,
    this.enabled = true,
    this.onChanged,
    super.key,
  });

  final String title;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Container(
        decoration: BoxDecoration(
          color: context.appTheme.beige900,
          border: Border.all(color: context.appTheme.strokeCard),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: context.appTheme.cardNavigation,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: subheadH3Medium.copyWith(color: context.appTheme.beige100),
              ),
              AppSwitch(
                value: value,
                onChanged: enabled
                    ? (v) {
                        unawaited(HapticFeedback.lightImpact());
                        onChanged?.call(v);
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
