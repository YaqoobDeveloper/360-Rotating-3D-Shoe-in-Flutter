import 'package:flutter/material.dart';

/// Brand palette for the Peppino Pizza app.
abstract final class AppColors {
  static const orange = Color(0xFFE9662C);
  static const orangeTint = Color(0xFFFDF0EA);
  static const background = Color(0xFFFFFFFF);

  /// Fill for inputs and other quiet surfaces.
  static const surfaceMuted = Color(0xFFF5F4F2);

  static const textPrimary = Color(0xFF17181A);
  static const textSecondary = Color(0xFF74767B);
  static const hint = Color(0xFFA1A3A8);
  static const border = Color(0xFFE7E5E2);
}

/// Shared corner radius so fields, buttons and tiles stay in one family.
const double kRadius = 14;

ThemeData buildAppTheme() {
  final colors = ColorScheme.fromSeed(
    seedColor: AppColors.orange,
    primary: AppColors.orange,
    surface: AppColors.background,
  );

  return ThemeData(
    colorScheme: colors,
    scaffoldBackgroundColor: AppColors.background,
    splashFactory: InkSparkle.splashFactory,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceMuted,
      hintStyle: const TextStyle(color: AppColors.hint, fontSize: 15),
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 15),
      floatingLabelStyle: const TextStyle(
        color: AppColors.orange,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      contentPadding: const EdgeInsets.fromLTRB(18, 12, 10, 14),
      // A filled, borderless box: the label floats inside it and the only
      // outline that ever shows is the focus/error underline.
      border: _fieldBorder(Colors.transparent),
      enabledBorder: _fieldBorder(Colors.transparent),
      focusedBorder: _fieldBorder(AppColors.orange, width: 2),
      errorBorder: _fieldBorder(colors.error),
      focusedErrorBorder: _fieldBorder(colors.error, width: 2),
      errorStyle: const TextStyle(fontSize: 12, height: 1.4),
    ),
  );
}

/// Dark counterpart of [buildAppTheme], used when the phone is set to dark.
ThemeData buildDarkAppTheme() {
  final colors = ColorScheme.fromSeed(
    seedColor: AppColors.orange,
    primary: AppColors.orange,
    brightness: Brightness.dark,
  );

  return ThemeData(
    colorScheme: colors,
    scaffoldBackgroundColor: const Color(0xFF101020),
    splashFactory: InkSparkle.splashFactory,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1B1B2E),
      hintStyle: const TextStyle(color: AppColors.hint, fontSize: 15),
      labelStyle: const TextStyle(color: AppColors.hint, fontSize: 15),
      floatingLabelStyle: const TextStyle(
        color: AppColors.orange,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      contentPadding: const EdgeInsets.fromLTRB(18, 12, 10, 14),
      border: _fieldBorder(Colors.transparent),
      enabledBorder: _fieldBorder(Colors.transparent),
      focusedBorder: _fieldBorder(AppColors.orange, width: 2),
      errorBorder: _fieldBorder(colors.error),
      focusedErrorBorder: _fieldBorder(colors.error, width: 2),
      errorStyle: const TextStyle(fontSize: 12, height: 1.4),
    ),
  );
}

UnderlineInputBorder _fieldBorder(Color color, {double width = 1}) {
  return UnderlineInputBorder(
    borderRadius: BorderRadius.circular(kRadius),
    borderSide: BorderSide(color: color, width: width),
  );
}
