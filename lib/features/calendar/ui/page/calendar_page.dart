import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/shared/calendar/calendar_piker.dart';
import 'package:reforge/shared/uikit/app_app_bar.dart';
import 'package:reforge/shared/uikit/default_background.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: Colors.transparent,
      appBar: AppAppBar(
        onPressed: () {
          Navigator.of(context).pop();
        },
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(
              'Forge Calendar',
              style: subheadH1Medium.copyWith(color: appTheme.beige100),
            ),
          ),
        ],
      ),
      body: const DefaultBackground(body: CalendarBody()),
    );
  }
}

class CalendarBody extends StatelessWidget {
  const CalendarBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const .all(16),
          child: Column(
            children: [
              Skeleton.leaf(
                child: Container(
                  padding: .symmetric(horizontal: 0, vertical: 12),
                  decoration: BoxDecoration(
                    //  color: const Color(0xFF180D05), // Базовый темный фон
                    borderRadius: BorderRadius.circular(20),
                    gradient: const RadialGradient(
                      center: .topLeft,

                      radius: 1.5,

                      colors: [
                        Color(0x994A2105),
                        Color(0x004A2105),
                      ],

                      stops: [0.53, 1.0],
                    ),

                    border: Border.all(
                      color: const Color(0xFFECE7DC).withValues(alpha: 0.1),
                    ),
                  ),
                  child: CalendarPicker(
                    headerTitle: 'Your Forge calendar',
                    needBottomLine: false,
                    initialDate: DateTime.now(),
                    firstDay: DateTime(1950),
                    lastDay: DateTime(2030),
                    onDateSelected: (date) => () {},
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
