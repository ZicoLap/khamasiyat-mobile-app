import 'package:flutter/material.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_colors.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_radii.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_spacing.dart';

/// Customer light theme — sporty, premium, mobile-first.
abstract final class AppTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primarySoft,
      onPrimaryContainer: AppColors.onPrimarySoft,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurfaceMuted,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineSubtle,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.light,
      visualDensity: VisualDensity.standard,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.canvas,
      textTheme: _textTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.canvas,
        foregroundColor: AppColors.onSurface,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        side: BorderSide.none,
        selectedColor: AppColors.primarySoft,
        backgroundColor: AppColors.surfaceMuted,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 2),
        showCheckmark: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 64,
        elevation: 0,
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primarySoft,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.primary : AppColors.onSurfaceMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 22,
            color: selected ? AppColors.primary : AppColors.onSurfaceMuted,
          );
        }),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.outlineSubtle,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size.fromHeight(52),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.onSurface,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: AppColors.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
        ),
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base) {
    return base.copyWith(
      displaySmall: base.displaySmall?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        height: 1.15,
        color: AppColors.onSurface,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
        height: 1.2,
        color: AppColors.onSurface,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: AppColors.onSurface,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        height: 1.4,
        color: AppColors.onSurface,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        height: 1.4,
        color: AppColors.onSurfaceMuted,
      ),
      bodySmall: base.bodySmall?.copyWith(
        height: 1.35,
        color: AppColors.onSurfaceMuted,
      ),
      labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      labelMedium: base.labelMedium?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}
