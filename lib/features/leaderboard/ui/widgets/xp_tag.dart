import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/formatters/xp_formatter.dart';
import 'package:reforge/shared/uikit/app_tag.dart';

class XpTag extends StatelessWidget {
  const XpTag({required this.xp, super.key});

  final int xp;

  @override
  Widget build(BuildContext context) {
    return AppTag(
      text: 'XP: ${XpFormatter.compact(xp, extSuffix: '')}',

      textStyle: subheadH8Semibold.copyWith(color: context.appTheme.beige100),
    );
  }
}
