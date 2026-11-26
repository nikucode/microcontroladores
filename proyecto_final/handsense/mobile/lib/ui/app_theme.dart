import 'package:flutter/material.dart';

abstract final class HandSenseColors {
  static const background = Color(0xfffbf9fe);
  static const ink = Color(0xff2e2546);
  static const muted = Color(0xff4f4866);
  static const primary = Color(0xff53448f);
  static const soft = Color(0xffe8e3f5);
  static const green = Color(0xff056641);
  static const amber = Color(0xff8a5600);
  static const border = Color(0xff7c7690);
  static const contrastInk = Color(0xff16121f);
  static const contrastMuted = Color(0xff332b40);
  static const contrastPrimary = Color(0xff38266b);
  static const contrastBorder = Color(0xff514b60);
}

ColorScheme handSenseColorScheme({required bool highContrast}) => ColorScheme(
  brightness: Brightness.light,
  primary: highContrast
      ? HandSenseColors.contrastPrimary
      : HandSenseColors.primary,
  onPrimary: Colors.white,
  primaryContainer: highContrast
      ? HandSenseColors.contrastPrimary
      : HandSenseColors.soft,
  onPrimaryContainer: highContrast ? Colors.white : HandSenseColors.ink,
  secondary: highContrast
      ? HandSenseColors.contrastPrimary
      : HandSenseColors.primary,
  onSecondary: Colors.white,
  secondaryContainer: highContrast
      ? HandSenseColors.contrastPrimary
      : HandSenseColors.soft,
  onSecondaryContainer: highContrast ? Colors.white : HandSenseColors.ink,
  tertiary: highContrast ? const Color(0xff704400) : HandSenseColors.amber,
  onTertiary: Colors.white,
  error: const Color(0xff9b1c1c),
  onError: Colors.white,
  surface: Colors.white,
  onSurface: highContrast ? HandSenseColors.contrastInk : HandSenseColors.ink,
  onSurfaceVariant: highContrast
      ? HandSenseColors.contrastMuted
      : HandSenseColors.muted,
  outline: highContrast
      ? HandSenseColors.contrastBorder
      : HandSenseColors.border,
  outlineVariant: highContrast
      ? HandSenseColors.contrastBorder
      : const Color(0xffdad3e9),
  surfaceContainer: highContrast ? Colors.white : const Color(0xfff2eef9),
);

ThemeData handSenseTheme({required bool highContrast}) {
  final scheme = handSenseColorScheme(highContrast: highContrast);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: highContrast
        ? Colors.white
        : HandSenseColors.background,
    textTheme: TextTheme(
      displaySmall: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
      headlineMedium: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      bodyLarge: const TextStyle(fontSize: 16, height: 1.4),
      bodyMedium: const TextStyle(fontSize: 16, height: 1.4),
      bodySmall: const TextStyle(fontSize: 14, height: 1.35),
    ).apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface),
    cardTheme: CardThemeData(
      color: scheme.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 72,
      backgroundColor: scheme.surfaceContainer,
      indicatorColor: scheme.secondaryContainer,
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? scheme.onSecondaryContainer
              : scheme.onSurfaceVariant,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          // La etiqueta queda fuera del indicador: siempre contrasta con la
          // superficie de la barra, no con el fondo del icono seleccionado.
          color: states.contains(WidgetState.selected)
              ? scheme.onSurface
              : scheme.onSurfaceVariant,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w500,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        foregroundColor: scheme.primary,
        side: BorderSide(color: scheme.outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 48),
        foregroundColor: scheme.primary,
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? scheme.onPrimary
            : scheme.onSurfaceVariant,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? scheme.primary
            : scheme.surfaceContainer,
      ),
      trackOutlineColor: WidgetStatePropertyAll(scheme.outline),
    ),
    focusColor: scheme.primary.withValues(alpha: .22),
  );
}

double contrastRatio(Color a, Color b) {
  final aLuminance = a.computeLuminance();
  final bLuminance = b.computeLuminance();
  final lighter = aLuminance > bLuminance ? aLuminance : bLuminance;
  final darker = aLuminance > bLuminance ? bLuminance : aLuminance;
  return (lighter + .05) / (darker + .05);
}
