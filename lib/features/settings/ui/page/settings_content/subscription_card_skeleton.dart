import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SubscriptionCardSkeleton extends StatelessWidget {
  const SubscriptionCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeleton.leaf(
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: context.appTheme.beige900,
          border: Border.all(color: context.appTheme.beige700),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 100,
                  height: 20,
                  color: context.appTheme.beige700,
                ),
                const Spacer(),
                Container(
                  width: 60,
                  height: 20,
                  color: context.appTheme.beige700,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    height: 16,
                    color: context.appTheme.beige700,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 50,
                  height: 16,
                  color: context.appTheme.beige700,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
