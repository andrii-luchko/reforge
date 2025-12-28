import 'package:flutter/material.dart';
import 'package:reforge/app/router/routes.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/shared/uikit/default_background.dart';
import 'package:reforge/features/auth/ui/widgets/auth_title.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/animations/shaders/sunrays_shader.dart';
import 'package:reforge/shared/uikit/app_app_bar.dart';
import 'package:reforge/shared/uikit/blur_container.dart';
import 'package:reforge/shared/uikit/buttons/primary_button.dart';
import 'package:reforge/shared/uikit/glass_container.dart';

class SuccessPasswordChangePage extends StatelessWidget {
  const SuccessPasswordChangePage({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppAppBar(
        onPressed: Navigator.of(context).pop,
      ),

      body: DefaultBackground(
        body: Positioned.fill(
          child: Padding(
            padding: const .symmetric(horizontal: 16),
            child: SafeArea(
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.15,
                  ),
                  Stack(
                    children: [
                      SizedBox(
                        height: 200,
                        width: 200,
                        child: SunRaysShaderWidget(
                          alignment: .center,
                          density: 4,
                          color: appTheme.orange400,
                        ),
                      ),

                      BlurContainer(
                        sigmaX: 20,
                        sigmaY: 20,
                        borderRadius: BorderRadius.circular(20),
                        child: SizedBox(
                          height: 200,
                          width: 200,
                          child: GlassContainer(
                            child: Image.asset(
                              Assets.images.png.goldEnvelopePlus.path,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: const .only(top: 32),
                    child: AuthTitle(
                      subtitle: t.success_password_change.subtitle,
                      title: t.success_password_change.title,
                    ),
                  ),
                  const Spacer(),
                  PrimaryButton(
                    text: t.success_password_change.submit_button,
                    onPressed: () async {
                      const SignInPageRoute().go(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
