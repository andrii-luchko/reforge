import 'package:flutter/material.dart';
import 'package:reforge/shared/app_cached_net_image.dart';

class AppImageWrapper extends StatelessWidget {
  const AppImageWrapper({
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.placeholder,
    super.key,
  });

  final String? imageUrl;
  final BoxFit fit;
  final Widget? placeholder;

  bool get _isNetwork => imageUrl != null && (imageUrl!.startsWith('http') || imageUrl!.startsWith('https'));
  bool get _isAsset => imageUrl != null && !_isNetwork;

  @override
  Widget build(BuildContext context) {
    final emptyWidget = placeholder ?? const AppUserImageEmptyWidget();

    if (imageUrl == null || imageUrl!.isEmpty) {
      return emptyWidget;
    }

    if (_isNetwork) {
      return AppCachedNetImage(
        imageUrl: imageUrl!,
        fit: fit,
      );
    }

    if (_isAsset) {
      return Image.asset(
        imageUrl!,
        fit: fit,
        errorBuilder: (_, _, _) => emptyWidget,
      );
    }

    return emptyWidget;
  }
}
