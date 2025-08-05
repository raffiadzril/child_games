import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/colors.dart';
import '../constants/dimensions.dart';
import '../constants/radius.dart';
import '../constants/fonts.dart';

/// Tema aplikasi yang ceria dan ramah anak
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryLight,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryLight,
        surface: AppColors.surface,
        background: AppColors.backgroundPrimary,
        error: AppColors.error,
        onPrimary: AppColors.textOnDark,
        onSecondary: AppColors.textOnDark,
        onSurface: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
        onError: AppColors.textOnDark,
        outline: AppColors.border,
        shadow: AppColors.shadow,
      ),

      // Typography
      textTheme: TextTheme(
        displayLarge: AppFonts.displayLarge,
        displayMedium: AppFonts.displayMedium,
        displaySmall: AppFonts.displaySmall,
        headlineLarge: AppFonts.headlineLarge,
        headlineMedium: AppFonts.headlineMedium,
        headlineSmall: AppFonts.headlineSmall,
        titleLarge: AppFonts.titleLarge,
        titleMedium: AppFonts.titleMedium,
        titleSmall: AppFonts.titleSmall,
        bodyLarge: AppFonts.bodyLarge,
        bodyMedium: AppFonts.bodyMedium,
        bodySmall: AppFonts.bodySmall,
        labelLarge: AppFonts.labelLarge,
        labelMedium: AppFonts.labelMedium,
        labelSmall: AppFonts.labelSmall,
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        elevation: AppDimensions.elevationNone,
        backgroundColor: AppColors.backgroundPrimary,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: AppFonts.headlineMedium,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),

      // Card Theme
      cardTheme: CardTheme(
        elevation: AppDimensions.elevationS,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.radiusCard),
        ),
        color: AppColors.backgroundCard,
        shadowColor: AppColors.shadow,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: AppDimensions.elevationS,
          minimumSize: const Size(
            AppDimensions.minButtonWidth,
            AppDimensions.buttonHeightM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.radiusButton),
          ),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnDark,
          textStyle: AppFonts.gameButton,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
            vertical: AppDimensions.paddingM,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(
            AppDimensions.minButtonWidth,
            AppDimensions.buttonHeightM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.radiusButton),
          ),
          side: const BorderSide(
            color: AppColors.primary,
            width: AppDimensions.borderWidthMedium,
          ),
          foregroundColor: AppColors.primary,
          textStyle: AppFonts.gameButton,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
            vertical: AppDimensions.paddingM,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(
            AppDimensions.minButtonWidth,
            AppDimensions.buttonHeightM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.radiusButton),
          ),
          foregroundColor: AppColors.primary,
          textStyle: AppFonts.gameButton,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
            vertical: AppDimensions.paddingM,
          ),
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.textOnDark,
        elevation: AppDimensions.elevationM,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.radiusFAB)),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.backgroundSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.radiusInput),
          borderSide: const BorderSide(
            color: AppColors.border,
            width: AppDimensions.borderWidthThin,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.radiusInput),
          borderSide: const BorderSide(
            color: AppColors.border,
            width: AppDimensions.borderWidthThin,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.radiusInputFocused),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: AppDimensions.borderWidthMedium,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.radiusInput),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: AppDimensions.borderWidthMedium,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingL,
          vertical: AppDimensions.paddingM,
        ),
        hintStyle: AppFonts.bodyMedium.copyWith(color: AppColors.textTertiary),
        labelStyle: AppFonts.labelMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.backgroundCard,
        selectedColor: AppColors.primaryLight,
        disabledColor: AppColors.borderLight,
        labelStyle: AppFonts.labelMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.radiusChip),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingS,
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogTheme(
        elevation: AppDimensions.elevationL,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.radiusDialog),
        ),
        backgroundColor: AppColors.backgroundSecondary,
        titleTextStyle: AppFonts.headlineSmall.copyWith(
          color: AppColors.textPrimary,
        ),
        contentTextStyle: AppFonts.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        elevation: AppDimensions.elevationL,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.radiusBottomSheet),
          ),
        ),
        backgroundColor: AppColors.backgroundSecondary,
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.borderLight,
        circularTrackColor: AppColors.borderLight,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: AppDimensions.borderWidthThin,
        space: AppDimensions.paddingM,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.textSecondary,
        size: AppDimensions.iconM,
      ),

      // Primary Icon Theme
      primaryIconTheme: const IconThemeData(
        color: AppColors.textOnDark,
        size: AppDimensions.iconM,
      ),
    );
  }

  // Dark theme untuk masa depan jika diperlukan
  static ThemeData get darkTheme {
    // Implementasi dark theme bisa ditambahkan nanti
    return lightTheme;
  }
}
