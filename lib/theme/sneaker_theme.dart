import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color kPrimaryGreen = Color(0xFF3A8F4B);
const Color kHeroGrey = Color(0xFFEFEFEF);
const Color kTextDark = Color(0xFF1A1A1A);
const Color kTextMuted = Color(0xFF8E8E8E);
const Color kStroke = Color(0xFFE9E9E9);

/// Plus Jakarta Sans at the given weight.
///
/// google_fonts registers each weight as its own family, so a weight must be
/// chosen here, not via `copyWith(fontWeight: ...)` afterwards, or Flutter
/// fakes the bold from the regular file.
TextStyle jakarta({
  double? fontSize,
  FontWeight fontWeight = FontWeight.w400,
  Color? color,
  double? height,
  double? letterSpacing,
}) {
  return GoogleFonts.plusJakartaSans(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
  );
}

ThemeData buildSneakerTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: kPrimaryGreen,
      primary: kPrimaryGreen,
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.white,
  );
  return base.copyWith(textTheme: _withJakarta(base.textTheme));
}

TextStyle? _j(TextStyle? style) =>
    style == null ? null : GoogleFonts.plusJakartaSans(textStyle: style);

// google_fonts 9 is built on package:material_ui, whose TextTheme type differs
// from flutter/material's, so the theme is mapped style by style.
TextTheme _withJakarta(TextTheme t) => TextTheme(
  displayLarge: _j(t.displayLarge),
  displayMedium: _j(t.displayMedium),
  displaySmall: _j(t.displaySmall),
  headlineLarge: _j(t.headlineLarge),
  headlineMedium: _j(t.headlineMedium),
  headlineSmall: _j(t.headlineSmall),
  titleLarge: _j(t.titleLarge),
  titleMedium: _j(t.titleMedium),
  titleSmall: _j(t.titleSmall),
  bodyLarge: _j(t.bodyLarge),
  bodyMedium: _j(t.bodyMedium),
  bodySmall: _j(t.bodySmall),
  labelLarge: _j(t.labelLarge),
  labelMedium: _j(t.labelMedium),
  labelSmall: _j(t.labelSmall),
);
