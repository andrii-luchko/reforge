// dart format width=120

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/widgets.dart';

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// Directory path: assets/images/icons
  $AssetsImagesIconsGen get icons => const $AssetsImagesIconsGen();

  /// Directory path: assets/images/png
  $AssetsImagesPngGen get png => const $AssetsImagesPngGen();

  /// Directory path: assets/images/svg
  $AssetsImagesSvgGen get svg => const $AssetsImagesSvgGen();
}

class $AssetsImagesIconsGen {
  const $AssetsImagesIconsGen();

  /// File path: assets/images/icons/apple.svg
  String get apple => 'assets/images/icons/apple.svg';

  /// File path: assets/images/icons/check.svg
  String get check => 'assets/images/icons/check.svg';

  /// File path: assets/images/icons/eye.svg
  String get eye => 'assets/images/icons/eye.svg';

  /// File path: assets/images/icons/eye_slash.svg
  String get eyeSlash => 'assets/images/icons/eye_slash.svg';

  /// File path: assets/images/icons/google.svg
  String get google => 'assets/images/icons/google.svg';

  /// List of all assets
  List<String> get values => [apple, check, eye, eyeSlash, google];
}

class $AssetsImagesPngGen {
  const $AssetsImagesPngGen();

  /// File path: assets/images/png/Faction.png
  AssetGenImage get faction => const AssetGenImage('assets/images/png/Faction.png');

  /// File path: assets/images/png/foreground-512x512.png
  AssetGenImage get foreground512x512 => const AssetGenImage('assets/images/png/foreground-512x512.png');

  /// File path: assets/images/png/gold_envelope.png
  AssetGenImage get goldEnvelope => const AssetGenImage('assets/images/png/gold_envelope.png');

  /// File path: assets/images/png/gold_envelope_plus.png
  AssetGenImage get goldEnvelopePlus => const AssetGenImage('assets/images/png/gold_envelope_plus.png');

  /// File path: assets/images/png/icon-1024x1024.png
  AssetGenImage get icon1024x1024 => const AssetGenImage('assets/images/png/icon-1024x1024.png');

  /// File path: assets/images/png/noise_and_texture.png
  AssetGenImage get noiseAndTexture => const AssetGenImage('assets/images/png/noise_and_texture.png');

  /// File path: assets/images/png/smoke.png
  AssetGenImage get smoke => const AssetGenImage('assets/images/png/smoke.png');

  /// File path: assets/images/png/splash_logo.png
  AssetGenImage get splashLogo => const AssetGenImage('assets/images/png/splash_logo.png');

  /// List of all assets
  List<AssetGenImage> get values => [
    faction,
    foreground512x512,
    goldEnvelope,
    goldEnvelopePlus,
    icon1024x1024,
    noiseAndTexture,
    smoke,
    splashLogo,
  ];
}

class $AssetsImagesSvgGen {
  const $AssetsImagesSvgGen();

  /// File path: assets/images/svg/logo.svg
  String get logo => 'assets/images/svg/logo.svg';

  /// File path: assets/images/svg/logo_and_name.svg
  String get logoAndName => 'assets/images/svg/logo_and_name.svg';

  /// File path: assets/images/svg/logo_splash.svg
  String get logoSplash => 'assets/images/svg/logo_splash.svg';

  /// List of all assets
  List<String> get values => [logo, logoAndName, logoSplash];
}

class Assets {
  const Assets._();

  static const $AssetsImagesGen images = $AssetsImagesGen();
}

class AssetGenImage {
  const AssetGenImage(this._assetName, {this.size, this.flavors = const {}, this.animation});

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({required this.isAnimation, required this.duration, required this.frames});

  final bool isAnimation;
  final Duration duration;
  final int frames;
}
