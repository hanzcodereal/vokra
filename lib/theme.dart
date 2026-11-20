import 'package:flutter/material.dart';

class VokraTheme {
  static const Color primary = Color(0xFFCC785C);
  static const Color primaryActive = Color(0xFFA9583E);
  static const Color primaryDisabled = Color(0xFFE6DFD8);

  static const Color ink = Color(0xFF141413);
  static const Color body = Color(0xFF3D3D3A);
  static const Color bodyStrong = Color(0xFF252523);
  static const Color muted = Color(0xFF6C6A64);
  static const Color mutedSoft = Color(0xFF8E8B82);

  static const Color hairline = Color(0xFFE6DFD8);
  static const Color hairlineSoft = Color(0xFFEBE6DF);

  static const Color canvas = Color(0xFFFAF9F5);
  static const Color surfaceSoft = Color(0xFFF5F0E8);
  static const Color surfaceCard = Color(0xFFEFE9DE);
  static const Color surfaceCreamStrong = Color(0xFFE8E0D2);

  static const Color surfaceDark = Color(0xFF181715);
  static const Color surfaceDarkElevated = Color(0xFF252320);
  static const Color surfaceDarkSoft = Color(0xFF1F1E1B);

  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onDark = Color(0xFFFAF9F5);
  static const Color onDarkSoft = Color(0xFFA09D96);

  static const Color accentTeal = Color(0xFF5DB8A6);
  static const Color accentAmber = Color(0xFFE8A55A);
  static const Color success = Color(0xFF5DB872);
  static const Color warning = Color(0xFFD4A017);
  static const Color error = Color(0xFFC64545);

  static const String fontDisplay = 'Orbitron';
  static const String fontBody = 'ShareTechMono';
  static const String fontMono = 'ShareTechMono';

  static const TextStyle displayXl = TextStyle(
    fontFamily: fontDisplay, fontSize: 40, fontWeight: FontWeight.w400,
    height: 1.1, letterSpacing: 1.0, color: ink,
  );
  static const TextStyle displayLg = TextStyle(
    fontFamily: fontDisplay, fontSize: 30, fontWeight: FontWeight.w400,
    height: 1.15, letterSpacing: 0.8, color: ink,
  );
  static const TextStyle displayMd = TextStyle(
    fontFamily: fontDisplay, fontSize: 22, fontWeight: FontWeight.w400,
    height: 1.2, letterSpacing: 0.6, color: ink,
  );
  static const TextStyle displaySm = TextStyle(
    fontFamily: fontDisplay, fontSize: 18, fontWeight: FontWeight.w400,
    height: 1.2, letterSpacing: 0.4, color: ink,
  );
  static const TextStyle titleLg = TextStyle(
    fontFamily: fontDisplay, fontSize: 16, fontWeight: FontWeight.w400,
    height: 1.3, letterSpacing: 0.3, color: ink,
  );
  static const TextStyle titleMd = TextStyle(
    fontFamily: fontDisplay, fontSize: 14, fontWeight: FontWeight.w400,
    height: 1.4, letterSpacing: 0.3, color: ink,
  );
  static const TextStyle titleSm = TextStyle(
    fontFamily: fontDisplay, fontSize: 13, fontWeight: FontWeight.w400,
    height: 1.4, letterSpacing: 0.2, color: ink,
  );
  static const TextStyle bodyMd = TextStyle(
    fontFamily: fontBody, fontSize: 15, fontWeight: FontWeight.w400,
    height: 1.5, letterSpacing: 0.2, color: body,
  );
  static const TextStyle bodySm = TextStyle(
    fontFamily: fontBody, fontSize: 13, fontWeight: FontWeight.w400,
    height: 1.45, letterSpacing: 0.2, color: body,
  );
  static const TextStyle caption = TextStyle(
    fontFamily: fontBody, fontSize: 12, fontWeight: FontWeight.w400,
    height: 1.4, letterSpacing: 0.4, color: muted,
  );
  static const TextStyle captionUpper = TextStyle(
    fontFamily: fontDisplay, fontSize: 10, fontWeight: FontWeight.w400,
    height: 1.4, letterSpacing: 2.0, color: muted,
  );
  static const TextStyle code = TextStyle(
    fontFamily: fontMono, fontSize: 13, fontWeight: FontWeight.w400,
    height: 1.6, letterSpacing: 0.2, color: onDark,
  );
  static const TextStyle button = TextStyle(
    fontFamily: fontDisplay, fontSize: 13, fontWeight: FontWeight.w400,
    height: 1.0, letterSpacing: 1.2, color: onPrimary,
  );

  static const double rXs = 4;
  static const double rSm = 6;
  static const double rMd = 8;
  static const double rLg = 12;
  static const double rXl = 16;
  static const double rPill = 9999;

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: canvas,
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: onPrimary,
        surface: canvas,
        onSurface: ink,
        error: error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: canvas,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: titleMd,
      ),
      textTheme: base.textTheme.apply(
        fontFamily: fontBody,
        bodyColor: body,
        displayColor: ink,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          minimumSize: const Size.fromHeight(46),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rMd)),
          textStyle: button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          side: const BorderSide(color: hairline),
          minimumSize: const Size.fromHeight(46),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rMd)),
          textStyle: button.copyWith(color: ink),
        ),
      ),
      dividerColor: hairline,
      cardTheme: CardTheme(
        color: surfaceCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rLg),
          side: const BorderSide(color: hairlineSoft),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: primary),
    );
  }
}
