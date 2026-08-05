import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/features/home/controller/cubit/home_cubit.dart';
import 'package:reforge/features/home/ui/guide/main_page_guide_host.dart';
import 'package:reforge/features/home/ui/widgets/home_body.dart';
import 'package:reforge/shared/animations/particles/particles.dart';
import 'package:reforge/shared/animations/shaders/sunrays_shader.dart';
import 'package:reforge/shared/uikit/default_background.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeCubit cubit = context.read<HomeCubit>();

  @override
  void initState() {
    super.initState();
    unawaited(cubit.ensureInitialDataLoaded());
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: Colors.transparent,
      floatingActionButtonLocation: .endTop,
      // floatingActionButton: kDebugMode
      //     ? FloatingActionButton(
      //         onPressed: () async {},
      //       )
      //     : null,
      body: MainPageGuideHost(
        child: DefaultBackground(
          body: const HomeBody(),
          additionalAnimationsOnTop: [
            Positioned.fill(
              child: SunRaysShaderWidget.home(color: appTheme.orange500),
            ),
          ],
          additionalAnimationsBehind: const [ParticlesWidget()],
        ),
      ),
    );
  }
}
