import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:reforge/app/router/routes.dart';

import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';

import 'package:reforge/generated/flutter_gen/assets.gen.dart';

import 'package:reforge/shared/uikit/buttons/icon_button.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  Future<void> navigateToCalendar(BuildContext context) async {
    // ignore: inference_failure_on_function_invocation
    await const CalendarPageRoute().push(context);
  }

  void navigateToNotifications() {}

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Padding(
      padding: const .symmetric(horizontal: 16),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: appTheme.beige100,
                shape: BoxShape.circle,
                border: GradientBoxBorder(gradient: appTheme.avatarGradient, width: 2),
              ),
              child: Center(child: SvgPicture.asset(Assets.images.icons.user)),
            ),

            Padding(
              padding: const .only(left: 10),
              child: Column(
                mainAxisAlignment: .center,
                crossAxisAlignment: .start,
                children: [
                  Text('Welcome back', style: subheadH5Medium.copyWith(color: appTheme.beige500)),
                  Text('Hey, Jacob!', style: subheadH1Medium.copyWith(color: appTheme.beige100)),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const .only(right: 8),
              child: AppIconButton(
                iconAsset: Assets.images.icons.calendar,
                onPressed: () => navigateToCalendar(context),
              ),
            ),

            AppIconButton(
              iconAsset: Assets.images.icons.bell,
              onPressed: navigateToNotifications,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const .fromHeight(kToolbarHeight + 16);
}
