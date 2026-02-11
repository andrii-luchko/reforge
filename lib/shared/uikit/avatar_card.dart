import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/features/achievements/domain/entities/rank_entity.dart';
import 'package:reforge/features/home/ui/widgets/faction_widget.dart';
import 'package:reforge/features/home/ui/widgets/lvl_widget.dart';
import 'package:reforge/features/home/ui/widgets/rank_card.dart';
import 'package:reforge/features/home/ui/widgets/xp_indicator.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AvatarCardShimmer extends StatelessWidget {
  const AvatarCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return _AvatarCardBase(
      child: ClipPath(clipper: AvatarClipper(), child: const Bone()),
    );
  }
}

class _AvatarCardBase extends StatelessWidget {
  const _AvatarCardBase({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return AspectRatio(
      aspectRatio: 358 / 484,
      child: FittedBox(
        child: Container(
          width: 350,
          height: 480,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: appTheme.beige900,
            borderRadius: .circular(10),
            border: GradientBoxBorder(
              gradient: LinearGradient(
                colors: [
                  appTheme.beige100.withValues(alpha: 0.6),
                  appTheme.beige100.withValues(alpha: 0),
                ],
              ),
            ),
          ),

          child: child,
        ),
      ),
    );
  }
}

class AvatarRankCard extends StatelessWidget {
  const AvatarRankCard({
    required this.rank,
    super.key,
  });

  final RankEntity rank;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return _AvatarCardBase(
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
                      rank.imageUrl,
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
                  xp: rank.xp,
                  xpProgress: rank.progress,
                ),
              ),

              Positioned(
                top: 0,
                left: w * 0.08,
                child: LvlWidget(lvl: rank.lvl),
              ),

              Positioned(
                bottom: h * 0.25,
                left: w * 0.03,
                child: FactionWidget(faction: rank.faction.title(t)),
              ),

              Positioned(
                bottom: h * 0.02,
                left: w * 0.01,
                width: w * 0.93,

                child: RankCard(
                  rank: t.home.rank_label,
                  name: rank.rankName,
                ),
              ),
            ],
          );
        },
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
