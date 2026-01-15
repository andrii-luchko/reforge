import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/features/home/ui/widgets/faction_widget.dart';
import 'package:reforge/features/home/ui/widgets/lvl_widget.dart';
import 'package:reforge/features/home/ui/widgets/rank_card.dart';
import 'package:reforge/features/home/ui/widgets/xp_indicator.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';

class AvatarCard extends StatelessWidget {
  const AvatarCard({
    required this.faction,
    required this.lvl,
    required this.rankName,
    required this.xpValue,
    super.key,
  });

  final String faction;
  final String rankName;
  final int lvl;
  final double xpValue;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return AspectRatio(
      aspectRatio: 358 / 484,
      child: Container(
        width: double.infinity,

        decoration: BoxDecoration(
          color: appTheme.beige900,
          border: Border.all(color: appTheme.beige100.withValues(alpha: 0.4)),
        ),
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;

            return Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: AvatarBorderPainter(color: appTheme.beige100),
                    child: ClipPath(
                      clipper: AvatarClipper(),
                      child: Image.asset(
                        Assets.images.png.avatar.path,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: h * 0.04,
                  right: w * 0.02,
                  child: XpIndicatorWidget(
                    height: h * 0.4,
                    xp: 3800,
                    xpProgress: 0.8,
                  ),
                ),

                Positioned(
                  top: 0,
                  left: w * 0.08,
                  child: LvlWidget(lvl: lvl),
                ),

                Positioned(
                  bottom: h * 0.25,
                  left: w * 0.03,
                  child: FactionWidget(faction: faction),
                ),

                Positioned(
                  bottom: h * 0.02,
                  left: w * 0.01,
                  width: w * 0.93,

                  child: RankCard(
                    rank: 'Rank',
                    name: rankName,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class AvatarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return geAvatarSharpPath(size);
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class AvatarBorderPainter extends CustomPainter {
  AvatarBorderPainter({
    this.color = Colors.white,
    this.strokeWidth = 2.0,
  });

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final path = geAvatarSharpPath(size);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.square;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(AvatarBorderPainter oldDelegate) => false;
}

Path geAvatarSharpPath(Size size) {
  final path = Path();
  final w = size.width;
  final h = size.height;

  final cutSize = w / 12;
  final sideIndent = w / 7;
  final stepHeight = h / 3;

  path
    ..moveTo(0, 0)
    ..lineTo(w - sideIndent - cutSize, 0)
    ..lineTo(w - sideIndent, cutSize)
    ..lineTo(w - sideIndent, h - stepHeight)
    ..lineTo(w, h - stepHeight)
    ..lineTo(w, h)
    ..lineTo(0, h)
    ..close();

  return path;
}
