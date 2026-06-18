import 'package:flutter/material.dart';

import '../branding/branding_model.dart';

/// Builds a complete Material 3 [ThemeData] *from* the branding contract.
///
/// The seed color drives `ColorScheme.fromSeed`, guaranteeing a coherent,
/// accessible tonal palette for any brand. Optional role overrides from the
/// contract (primary / secondary / tertiary / error) are layered on top so a
/// brand can pin an exact color where it matters while letting FlavorFlow
/// generate the rest.
class AppTheme {
  const AppTheme._();

  static ThemeData fromBranding(Branding branding) {
    final colors = branding.colors;

    final baseScheme = ColorScheme.fromSeed(
      seedColor: colors.seed,
      brightness: colors.brightness == BrandBrightness.dark
          ? Brightness.dark
          : Brightness.light,
    );

    final scheme = baseScheme.copyWith(
      primary: colors.primary,
      secondary: colors.secondary,
      tertiary: colors.tertiary,
      error: colors.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        centerTitle: true,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
        ),
      ),
      cardTheme: const CardThemeData(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),
    );
  }
}
