import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/shared/uikit/buttons/icon_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: Colors.transparent,
      appBar: HomeAppBar(),
      body: HomeBody(),
      // floatingActionButton: FloatingActionButton(
      //   child: const Icon(Icons.logout),
      //   onPressed: () {
      //     context.read<AuthCubit>().signOut();
      //   },
      // ),
    );
  }
}

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  void navigateToCalendar() {}
  void navigateToNotifications() {}

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Padding(
      padding: const .symmetric(horizontal: 16),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: appTheme.beige100,
                shape: BoxShape.circle,
                border: GradientBoxBorder(gradient: appTheme.avatarGradient, width: 2),
              ),
              child: Center(child: SvgPicture.asset(Assets.images.icons.user)),
            ),

            Padding(
              padding: const .only(left: 10),
              child: Column(
                mainAxisAlignment: .center,
                crossAxisAlignment: .start,
                children: [
                  Text('Welcome back', style: subheadH5Medium.copyWith(color: appTheme.beige500)),
                  Text('Hey, Jacob!', style: subheadH1Medium.copyWith(color: appTheme.beige100)),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const .only(right: 8),
              child: AppIconButton(
                iconAsset: Assets.images.icons.calendar,
                onPressed: navigateToCalendar,
              ),
            ),

            AppIconButton(
              iconAsset: Assets.images.icons.bell,
              onPressed: navigateToNotifications,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const .fromHeight(kToolbarHeight + 12);
}

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [AvatarCard()],
        ),
      ),
    );
  }
}

class AvatarCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return AspectRatio(
      aspectRatio: 0.7,
      child: Container(
        decoration: BoxDecoration(
          color: appTheme.beige900,
          border: Border.all(color: appTheme.beige100.withValues(alpha: 0.4)),
        ),
        padding: const .all(16),
        margin: const .all(16),
        child: Stack(
          children: [
            Positioned(
              top: 0,

              right: 0,
              child: Column(
                children: [
                  RotatedBox(
                    quarterTurns: 3,
                    child: Text(
                      '3900xp',
                    ),
                  ),
                  XpBarIndicator(
                    progress: 1,
                  ),
                ],
              ),
            ),
            CustomPaint(
              painter: AvatarBorderPainter(color: appTheme.beige100),
              child: ClipPath(
                clipper: AvatarClipper(),
                child: Image.asset(
                  Assets.images.png.avatar.path,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
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

class XpBarIndicator extends StatelessWidget {
  final double progress; // От 0.0 до 1.0
  final double width;
  final double height;
  final Color color;

  const XpBarIndicator({
    Key? key,
    required this.progress,
    this.width = 22,
    this.height = 200,
    this.color = const Color(0xFF8B3A15),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _XpBarPainter(
          progress: progress,
          barColor: color,
          borderColor: Colors.white,
        ),
      ),
    );
  }
}

class _XpBarPainter extends CustomPainter {
  _XpBarPainter({
    required this.progress,
    required this.barColor,
    required this.borderColor,
  });

  final double progress;
  final Color barColor;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    const slopeFactor = 1.2;
    const padding = 3.0;

    final cutHeight = size.width * slopeFactor;

    final outlinePath = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, cutHeight)
      ..lineTo(size.width, size.height)
      ..close();

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas
      ..drawPath(outlinePath, borderPaint)
      ..save();

    final innerPath = Path()
      ..moveTo(padding, size.height - padding)
      ..lineTo(padding, padding + padding)
      ..lineTo(size.width - padding, cutHeight + padding)
      ..lineTo(size.width - padding, size.height - padding)
      ..close();

    canvas.clipPath(innerPath);

    final currentFillHeight = size.height * progress;
    final topCoord = size.height - currentFillHeight;

    canvas.clipRect(Rect.fromLTRB(0, topCoord, size.width, size.height));

    final stripePaint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;

    const stripeHeight = 10.0;
    const gap = 4.0;
    final stripeDrop = size.width * slopeFactor;

    for (var i = -size.width; i < size.height; i += stripeHeight + gap) {
      final stripePath = Path()
        ..moveTo(0, i)
        ..lineTo(size.width, i + stripeDrop)
        ..lineTo(size.width, i + stripeDrop + stripeHeight)
        ..lineTo(0, i + stripeHeight)
        ..close();

      canvas.drawPath(stripePath, stripePaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _XpBarPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.barColor != barColor ||
        oldDelegate.borderColor != borderColor;
  }
}
