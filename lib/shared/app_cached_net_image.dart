import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';

class AppCachedNetImage extends StatelessWidget {
  const AppCachedNetImage({required this.imageUrl, this.fit = BoxFit.cover, this.errorWidget, super.key});

  final String imageUrl;
  final BoxFit fit;
  final Widget? errorWidget;
  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      progressIndicatorBuilder: (context, url, progress) => ColoredBox(
        color: appTheme.beige200,
        child: Center(
          child: CircularProgressIndicator.adaptive(
            value: progress.progress,
            valueColor: AlwaysStoppedAnimation<Color>(appTheme.beige600),
          ),
        ),
      ),
      errorWidget: (context, url, error) => errorWidget ?? const AppImageErrorWidget(),
    );
  }
}

class AppImageErrorWidget extends StatelessWidget {
  const AppImageErrorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return ColoredBox(
      color: appTheme.beige200,
      child: Icon(
        Icons.image_not_supported_rounded,
        color: appTheme.beige600,
      ),
    );
  }
}

class AppUserImageEmptyWidget extends StatelessWidget {
  const AppUserImageEmptyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return ColoredBox(
      color: appTheme.beige100,
      child: Center(child: SvgPicture.asset(Assets.images.icons.user)),
    );
  }
}
