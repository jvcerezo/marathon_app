import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../design/tokens.dart';

class AppTheme {
  static ThemeData dark() {
    const cs = ColorScheme.dark(
      primary: AppColors.pulse,
      onPrimary: AppColors.ink,
      primaryContainer: Color(0xFF003D2A),
      onPrimaryContainer: AppColors.pulse,
      secondary: AppColors.ember,
      onSecondary: AppColors.ink,
      tertiary: AppColors.signal,
      onTertiary: AppColors.ink,
      surface: AppColors.ink,
      onSurface: AppColors.bone,
      surfaceContainerLowest: AppColors.ink,
      surfaceContainerLow: AppColors.shade,
      surfaceContainer: AppColors.slate,
      surfaceContainerHigh: AppColors.slate,
      surfaceContainerHighest: AppColors.iron,
      onSurfaceVariant: AppColors.mist,
      outline: AppColors.iron,
      outlineVariant: Color(0xFF1F2632),
      error: AppColors.miss,
      onError: AppColors.bone,
    );
    return _build(cs);
  }

  // Light theme is intentionally minimal for now; dark is the canonical look.
  static ThemeData light() {
    final cs = ColorScheme.fromSeed(
      seedColor: AppColors.pulse,
      brightness: Brightness.light,
    );
    return _build(cs);
  }

  static ThemeData _build(ColorScheme cs) {
    final isDark = cs.brightness == Brightness.dark;
    final base = ThemeData(
      colorScheme: cs,
      useMaterial3: true,
      scaffoldBackgroundColor: cs.surface,
      splashFactory: NoSplash.splashFactory,
    );

    final tt = base.textTheme;
    final display = tt.displayLarge!.copyWith(
      fontWeight: FontWeight.w900,
      letterSpacing: -2,
      height: 0.95,
      color: cs.onSurface,
    );

    return base.copyWith(
      textTheme: tt.copyWith(
        displayLarge: display.copyWith(fontSize: 96),
        displayMedium: display.copyWith(fontSize: 72),
        displaySmall: display.copyWith(fontSize: 48),
        headlineLarge: tt.headlineLarge?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: cs.onSurface,
        ),
        headlineMedium: tt.headlineMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
          color: cs.onSurface,
        ),
        headlineSmall: tt.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: cs.onSurface,
        ),
        titleLarge: tt.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: cs.onSurface,
        ),
        titleMedium: tt.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: cs.onSurface,
        ),
        bodyLarge: tt.bodyLarge?.copyWith(
          color: cs.onSurface,
          height: 1.4,
        ),
        bodyMedium: tt.bodyMedium?.copyWith(
          color: cs.onSurfaceVariant,
          height: 1.4,
        ),
        labelLarge: tt.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
          color: cs.onSurfaceVariant,
        ),
        labelMedium: tt.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
          color: cs.onSurfaceVariant,
        ),
        labelSmall: tt.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: cs.onSurfaceVariant,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: cs.onSurface,
          letterSpacing: -0.3,
        ),
        toolbarHeight: 60,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: cs.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          side: BorderSide(color: cs.outline, width: 1),
          foregroundColor: cs.onSurface,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cs.primary,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: cs.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: cs.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        filled: true,
        fillColor: cs.surfaceContainerHigh,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        labelStyle: TextStyle(color: cs.onSurfaceVariant),
        hintStyle: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cs.surfaceContainerHigh,
        selectedColor: cs.primary,
        labelStyle: TextStyle(
          color: cs.onSurface,
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: TextStyle(
          color: cs.onPrimary,
          fontWeight: FontWeight.w700,
        ),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        showCheckmark: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cs.surfaceContainerLow,
        elevation: 0,
        height: 72,
        indicatorColor: cs.primary.withValues(alpha: 0.18),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
            color: cs.onSurface,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? cs.primary : cs.onSurfaceVariant,
            size: 24,
          );
        }),
      ),
      dividerTheme: DividerThemeData(
        color: cs.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: cs.primary,
        linearTrackColor: cs.surfaceContainerHigh,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cs.surfaceContainerHighest,
        contentTextStyle: TextStyle(color: cs.onSurface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }
}
