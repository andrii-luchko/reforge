import 'package:flutter/widgets.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/shared/animations/shaders/particles_shader.dart';

class DefaultBackground extends StatelessWidget {
  const DefaultBackground({
    required this.body,
    this.loader,
    this.additionalAnimations = const [],
    super.key,
  });

  final Widget body;
  final Positioned? loader;
  final List<Widget> additionalAnimations;
  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          //const Positioned.fill(child: ParticlesShaderWidget()),
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

          ...additionalAnimations,

          body,

          ?loader,
        ],
      ),
    );
  }
}
