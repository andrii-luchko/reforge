import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';

class RankCard extends StatelessWidget {
  const RankCard({
    required this.rank,
    required this.name,
    super.key,
  });
  final String rank;
  final String name;

  static const double _cardAspectRatio = 312 / 93;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _cardAspectRatio,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;

          return Stack(
            children: [
              Positioned.fill(
                child: SvgPicture.asset(
                  Assets.images.svg.rankCard,
                  fit: BoxFit.fill,
                ),
              ),

              Positioned(
                left: w * 0.1,
                top: h * 0.10,
                right: w * 0.1,
                bottom: h * 0.2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          rank,
                          style: subheadH4Semibold.copyWith(
                            color: context.appTheme.beige800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          name,
                          style: titleH2Regular.copyWith(
                            color: context.appTheme.beige800,
                            fontSize: 100,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
