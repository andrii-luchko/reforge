import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:reforge/app/theme/app_theme.dart';

class AppCachedNetImage extends StatelessWidget {
  const AppCachedNetImage({required this.imageUrl, super.key});

  final String imageUrl;
  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      progressIndicatorBuilder: (context, url, progress) => ColoredBox(
        color: appTheme.beige200,
        child: Center(
          child: CircularProgressIndicator.adaptive(
            value: progress.progress,
            valueColor: AlwaysStoppedAnimation<Color>(appTheme.beige600),
          ),
        ),
      ),
      errorWidget: (context, url, error) => const AppImageErrorWidget(),
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
