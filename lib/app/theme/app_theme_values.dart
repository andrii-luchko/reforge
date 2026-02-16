import 'package:flutter/widgets.dart';
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

    radioButtonGradient: const RadialGradient(
      center: Alignment(-0.88, -0.784),
      radius: 4.946,
      colors: [
        Color.fromARGB(0, 75, 33, 5),
        Color.fromARGB(106, 75, 33, 5),
        Color.fromARGB(185, 75, 33, 5),
      ],
      stops: [0.0, 0.6248, 1.0],
    ),

    gradientXpBar: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFDEB53B),
        Color(0xFF291F03),
      ],

      stops: [0.2, 0.9],
    ),

    strokeTag: LinearGradient(
      stops: const [0.1034, 0.9862],
      begin: const Alignment(-1, -0.2),
      end: const Alignment(1, 0.2),
      colors: [
        const Color(0xFFECE7DC).withValues(alpha: 0.4),
        const Color(0xFFECE7DC).withValues(alpha: 0),
      ],
    ),
    workoutContainerBorderRadius: const BorderRadius.all(Radius.circular(20)),
    workoutContainerConstrains: const BoxConstraints(maxHeight: 60, maxWidth: 60),

    silverGradient: const LinearGradient(
      colors: [
        Color(0xFFFFFFFF),
        Color(0xFF3E3D3A),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    goldGradient: const LinearGradient(
      colors: [
        Color(0xFFD4AF37),
        Color(0xFFF7EF8A),
        Color(0xFFB8860B),
        Color(0xFFD4AF37),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),

    bronzeGradient: const LinearGradient(
      colors: [
        Color(0xFFF3986E),
        Color(0xFF6F2807),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    ironGradient: const LinearGradient(
      colors: [
        Color(0xFF595959),
        Color(0xFF393838),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    steelGradient: const LinearGradient(
      colors: [
        Color(0xFF484747),
        Color(0xFF393838),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    woodGradient: const LinearGradient(
      colors: [
        Color(0xFFC66C32),
        Color(0xFFC66C32),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),

    sliverBottomSpacing: 100,

    cardNavigation: const LinearGradient(
      begin: Alignment(-0.53, -1),
      end: Alignment(0.96, 1),
      colors: [Color(0x009D3C10), Color(0x4D9D3C10)],
      stops: [0.6, 1.0],
    ),

    factionCardFillGradient: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: [0.53, 1.0],
      colors: [
        Color(0x004A2105),
        Color(0xFF4A2105),
      ],
    ),

    buttonConstrains: const BoxConstraints(
      maxHeight: 55,
      minHeight: 55,
    ),

    selectedGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: const Alignment(1, 2.5),

      stops: const [0.37, 1.0],
      colors: [
        const Color(0xFFC66C32),
        const Color(0xFFC66C32).withValues(alpha: 0),
      ],
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
    radioButtonGradient: const RadialGradient(
      center: Alignment(-0.88, -0.784),
      radius: 4.946,
      colors: [
        Color.fromARGB(0, 75, 33, 5),
        Color.fromARGB(106, 75, 33, 5),
        Color.fromARGB(185, 75, 33, 5),
      ],
      stops: [0.0, 0.6248, 1.0],
    ),

    gradientXpBar: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFDEB53B),
        Color(0xFF291F03),
      ],

      stops: [0.2, 0.9],
    ),

    strokeTag: LinearGradient(
      stops: const [0.1034, 0.9862],
      begin: const Alignment(-1, -0.2),
      end: const Alignment(1, 0.2),
      colors: [
        const Color(0xFFECE7DC).withValues(alpha: 0.4),
        const Color(0xFFECE7DC).withValues(alpha: 0),
      ],
    ),

    workoutContainerBorderRadius: const BorderRadius.all(Radius.circular(20)),
    workoutContainerConstrains: const BoxConstraints(maxHeight: 60),

    silverGradient: const LinearGradient(
      colors: [
        Color(0xFFFFFFFF),
        Color(0xFF3E3D3A),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    goldGradient: const LinearGradient(
      colors: [
        Color(0xFFD4AF37),
        Color(0xFFF7EF8A),
        Color(0xFFB8860B),
        Color(0xFFD4AF37),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),

    bronzeGradient: const LinearGradient(
      colors: [
        Color(0xFFF3986E),
        Color(0xFF6F2807),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    ironGradient: const LinearGradient(
      colors: [
        Color(0xFF595959),
        Color(0xFF393838),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    steelGradient: const LinearGradient(
      colors: [
        Color(0xFF484747),
        Color(0xFF393838),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    woodGradient: const LinearGradient(
      colors: [
        Color(0xFFC66C32),
        Color(0xFFC66C32),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),

    sliverBottomSpacing: 100,

    cardNavigation: const LinearGradient(
      begin: Alignment(-0.53, -1),
      end: Alignment(0.96, 1),
      colors: [Color(0x009D3C10), Color(0x4D9D3C10)],
      stops: [0.6, 1.0],
    ),

    factionCardFillGradient: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: [0.53, 1.0],
      colors: [
        Color(0x004A2105),
        Color(0xFF4A2105),
      ],
    ),

    buttonConstrains: const BoxConstraints(
      maxHeight: 55,
      minHeight: 55,
    ),

    selectedGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: const Alignment(1, 2.5),

      stops: const [0.37, 1.0],
      colors: [
        const Color(0xFFC66C32),
        const Color(0xFFC66C32).withValues(alpha: 0),
      ],
    ),
  );
}
