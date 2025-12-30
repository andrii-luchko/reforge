import 'package:flutter/painting.dart';
import 'package:reforge/app/theme/app_theme.dart';

class AppThemeValues {
  static final light = AppTheme(
    // Beige palette
    beige50: const Color(0xFF2C180B).withValues(alpha: 0.20),
    beige100: const Color(0xFFECE7DC),
    beige200: const Color(0xFFDED8CD),
    beige300: const Color(0xFFDFDAD3),
    beige400: const Color(0xFFDDD7CD),
    beige500: const Color(0xFFE2D4B1),
    beige600: const Color(0xFFA28675),
    beige700: const Color(0xFF927769),
    beige800: const Color(0xFF3B2518),
    beige900: const Color(0xFF180D05),
    beige1000: const Color(0xFF0F0802),

    // Orange palette
    orange100: const Color(0xFFCA5F1C).withValues(alpha: 0.30),
    orange200: const Color(0xFFEEBCA4),
    orange300: const Color(0xFFBB623A),
    orange400: const Color(0xFF9D3C10),
    orange500: const Color(0xFF9D3C10),
    orange600: const Color(0xFF4B2105),
    orange60: const Color(0xFF9D3C10).withValues(alpha: 0.60),
    orangeButton: const Color(0xFF9D3C10).withValues(alpha: 0.60),

    styleCard: const LinearGradient(
      begin: .bottomCenter,
      end: .topCenter,
      stops: [0.6, 1],
      colors: [
        Color(0xFF180D05),
        Color(0xFF4A2105),
      ],
    ),

    strokeCard: const Color(0xFF2B221A),
    strokeCalendar: const Color(0xFFC66C32),
    red400: const Color(0xFFCF6B6B),

    avatarGradient: const RadialGradient(
      colors: [
        Color(0xFFD4AD38),
        Color(0xFF5D4B17),
      ],
    ),

    menuBar: const LinearGradient(
      begin: Alignment(-1, -0.03),
      end: Alignment(1, 0.03),
      stops: [0.0464, 1.2027],
      colors: [
        Color.fromRGBO(223, 218, 211, 0.2),
        Color.fromRGBO(223, 218, 211, 0),
      ],
    ),

    menuButton: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,

      colors: [
        Color.fromRGBO(223, 218, 211, 0.4),
        Color.fromRGBO(223, 218, 211, 0),
      ],

      stops: [0.1206, 0.9018],
    ),
  );

  static final dark = AppTheme(
    // Beige palette
    beige50: const Color(0xFF2C180B).withValues(alpha: 0.20),
    beige100: const Color(0xFFECE7DC),
    beige200: const Color(0xFFDED8CD),
    beige300: const Color(0xFFDFDAD3),
    beige400: const Color(0xFFDDD7CD),
    beige500: const Color(0xFFE2D4B1),
    beige600: const Color(0xFFA28675),
    beige700: const Color(0xFF927769),
    beige800: const Color(0xFF3B2518),
    beige900: const Color(0xFF180D05),
    beige1000: const Color(0xFF0F0802),

    // Orange palette
    orange100: const Color(0xFFCA5F1C).withValues(alpha: 0.30),
    orange200: const Color(0xFFEEBCA4),
    orange300: const Color(0xFFBB623A),
    orange400: const Color(0xFF9D3C10),
    orange500: const Color(0xFF9D3C10),
    orange600: const Color(0xFF4B2105),
    orange60: const Color(0xFF9D3C10).withValues(alpha: 0.60),
    orangeButton: const Color(0xFF9D3C10).withValues(alpha: 0.60),

    styleCard: const LinearGradient(
      begin: .bottomCenter,
      end: .topCenter,
      stops: [0.6, 1],
      colors: [
        Color(0xFF180D05),
        Color(0xFF4A2105),
      ],
    ),

    strokeCard: const Color(0xFF2B221A),
    strokeCalendar: const Color(0xFFC66C32),
    red400: const Color(0xFFCF6B6B),
    avatarGradient: const RadialGradient(colors: [Color(0xFFD4AD38), Color(0xFF5D4B17)]),

    menuBar: const LinearGradient(
      begin: Alignment(-1, -0.03),
      end: Alignment(1, 0.03),
      stops: [0.0464, 1.2027],
      colors: [
        Color.fromRGBO(223, 218, 211, 0.2),
        Color.fromRGBO(223, 218, 211, 0),
      ],
    ),

    menuButton: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,

      colors: [
        Color.fromRGBO(223, 218, 211, 0.4),
        Color.fromRGBO(223, 218, 211, 0),
      ],

      stops: [0.1206, 0.9018],
    ),
  );
}
