import 'package:flutter/widgets.dart';

extension TextStyleX on TextStyle {
  StrutStyle get strut => StrutStyle.fromTextStyle(
    this,
    forceStrutHeight: true,
  );
}
