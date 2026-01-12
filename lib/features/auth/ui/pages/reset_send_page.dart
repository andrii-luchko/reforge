import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/features/auth/controllers/forgot_password/forgot_password_cubit.dart';
import 'package:reforge/features/auth/ui/pages/forgot_password_email_page.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/animations/shaders/sunrays_shader.dart';
import 'package:reforge/shared/uikit/app_app_bar.dart';
import 'package:reforge/shared/uikit/blur_container.dart';
import 'package:reforge/shared/uikit/buttons/primary_button.dart';
import 'package:reforge/shared/uikit/default_background.dart';
import 'package:reforge/shared/uikit/glass_container.dart';

class ResetSendPage extends StatefulWidget {
  const ResetSendPage({required this.email, super.key});

  final String email;

  @override
  State<ResetSendPage> createState() => _ResetSendPageState();
}

class _ResetSendPageState extends State<ResetSendPage> {
  bool _canResend = false;
  Timer? _timer;

  static const int _timeoutSeconds = 10;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _canResend = false;
    });

    _timer = Timer(const Duration(seconds: _timeoutSeconds), () {
      if (mounted) {
        setState(() {
          _canResend = true;
        });
      }
    });
  }

  Future<void> _onResendPressed() async {
    logger.d('Resending email to ${widget.email}...');

    await context.read<ForgotPasswordCubit>().submit();

    _startTimer();
  }

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
                                text: widget.email,
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
                    onPressed: _canResend ? _onResendPressed : null,
                  ),
                ],
              ),
            ),
          ),
        ),
        loader: const Positioned.fill(child: ForgotPasswordLoader()),
      ),
    );
  }
}
