import 'package:flutter/widgets.dart';
import 'package:reforge/shared/uikit/avatar_rank_card/helper/shape_avatar_card.dart';

class AvatarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return geAvatarSharpPath(size);
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
