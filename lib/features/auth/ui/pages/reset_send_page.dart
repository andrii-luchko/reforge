import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/animations/shaders/particles_shader.dart';
import 'package:reforge/shared/animations/shaders/sunrays_shader.dart';
import 'package:reforge/shared/uikit/app_app_bar.dart';
import 'package:reforge/shared/uikit/blur_container.dart';
import 'package:reforge/shared/uikit/buttons/primary_button.dart';
import 'package:reforge/shared/uikit/glass_container.dart';

class ResetSendPage extends StatelessWidget {
  const ResetSendPage({required this.email, super.key});

  final String email;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppAppBar(
        onPressed: Navigator.of(context).pop,
      ),

      body: SizedBox.expand(
        child: Stack(
          children: [
            const Positioned.fill(child: ParticlesShaderWidget()),
            Positioned.fill(
              child: Image.asset(
                Assets.images.png.smoke.path,
                fit: .fill,
                opacity: const AlwaysStoppedAnimation<double>(0.5),
              ),
            ),

            Positioned.fill(
              child: Image.asset(
                Assets.images.png.noiseAndTexture.path,
                fit: .fill,
              ),
            ),

            Positioned.fill(
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
                              density: 3,
                              intensity: 5,
                              rayLength: 0.5,

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
                                  Assets.images.png.goldEnvelope.path,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      Padding(
                        padding: const .only(top: 32),
                        child: Column(
                          children: [
                            Text(
                              t.reset_send.title,
                              style: subheadH1Medium.copyWith(color: context.appTheme.beige100),
                            ),

                            Padding(
                              padding: const .only(top: 16),
                              child: Text.rich(
                                textAlign: .center,
                                style: bodyLRegular.copyWith(color: context.appTheme.beige600),
                                t.reset_send.subtitle(
                                  email: TextSpan(
                                    text: email,
                                    style: bodyLRegular.copyWith(color: context.appTheme.beige100),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),
                      PrimaryButton(
                        text: t.reset_send.submit_button,
                        onPressed: () async {
                          logger.d('reforge://app/create-new-password?token=test123');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
