import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Font families dan text styles yang ramah anak
class AppFonts {
  // Font families - Using Google Fonts
  static String get primaryFont => GoogleFonts.poppins().fontFamily!;
  static String get secondaryFont => GoogleFonts.nunito().fontFamily!;
  static String get gameFont => GoogleFonts.comicNeue().fontFamily!;

  // Font weights
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;

  // Font sizes
  static const double fontSizeXS = 10.0;
  static const double fontSizeS = 12.0;
  static const double fontSizeM = 14.0;
  static const double fontSizeL = 16.0;
  static const double fontSizeXL = 18.0;
  static const double fontSizeXXL = 20.0;
  static const double fontSizeXXXL = 24.0;

  // Heading font sizes
  static const double fontSizeH1 = 32.0;
  static const double fontSizeH2 = 28.0;
  static const double fontSizeH3 = 24.0;
  static const double fontSizeH4 = 20.0;
  static const double fontSizeH5 = 18.0;
  static const double fontSizeH6 = 16.0;

  // Line heights
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.4;
  static const double lineHeightRelaxed = 1.6;
  static const double lineHeightLoose = 1.8;

  // Letter spacing
  static const double letterSpacingTight = -0.5;
  static const double letterSpacingNormal = 0.0;
  static const double letterSpacingWide = 0.5;
  static const double letterSpacingWider = 1.0;

  // Text styles untuk konsistensi - Using Google Fonts directly
  static TextStyle get displayLarge => GoogleFonts.poppins(
    fontSize: fontSizeH1,
    fontWeight: bold,
    height: lineHeightTight,
    letterSpacing: letterSpacingTight,
  );

  static TextStyle get displayMedium => GoogleFonts.poppins(
    fontSize: fontSizeH2,
    fontWeight: bold,
    height: lineHeightTight,
    letterSpacing: letterSpacingTight,
  );

  static TextStyle get displaySmall => GoogleFonts.poppins(
    fontSize: fontSizeH3,
    fontWeight: semiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
  );

  static TextStyle get headlineLarge => GoogleFonts.poppins(
    fontSize: fontSizeH4,
    fontWeight: semiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
  );

  static TextStyle get headlineMedium => GoogleFonts.poppins(
    fontSize: fontSizeH5,
    fontWeight: medium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
  );

  static TextStyle get headlineSmall => GoogleFonts.poppins(
    fontSize: fontSizeH6,
    fontWeight: medium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
  );

  static TextStyle get titleLarge => GoogleFonts.poppins(
    fontSize: fontSizeXXL,
    fontWeight: medium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
  );

  static TextStyle get titleMedium => GoogleFonts.poppins(
    fontSize: fontSizeXL,
    fontWeight: medium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWide,
  );

  static TextStyle get titleSmall => GoogleFonts.poppins(
    fontSize: fontSizeL,
    fontWeight: medium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWide,
  );

  static TextStyle get bodyLarge => GoogleFonts.poppins(
    fontSize: fontSizeL,
    fontWeight: regular,
    height: lineHeightRelaxed,
    letterSpacing: letterSpacingWide,
  );

  static TextStyle get bodyMedium => GoogleFonts.poppins(
    fontSize: fontSizeM,
    fontWeight: regular,
    height: lineHeightRelaxed,
    letterSpacing: letterSpacingWide,
  );

  static TextStyle get bodySmall => GoogleFonts.poppins(
    fontSize: fontSizeS,
    fontWeight: regular,
    height: lineHeightRelaxed,
    letterSpacing: letterSpacingWide,
  );

  static TextStyle get labelLarge => GoogleFonts.poppins(
    fontSize: fontSizeM,
    fontWeight: medium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWide,
  );

  static TextStyle get labelMedium => GoogleFonts.poppins(
    fontSize: fontSizeS,
    fontWeight: medium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWide,
  );

  static TextStyle get labelSmall => GoogleFonts.poppins(
    fontSize: fontSizeXS,
    fontWeight: medium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWider,
  );

  // Game specific text styles
  static TextStyle get gameTitle => GoogleFonts.comicNeue(
    fontSize: fontSizeH2,
    fontWeight: bold,
    height: lineHeightTight,
    letterSpacing: letterSpacingNormal,
  );

  static TextStyle get gameScore => GoogleFonts.poppins(
    fontSize: fontSizeXXXL,
    fontWeight: extraBold,
    height: lineHeightTight,
    letterSpacing: letterSpacingTight,
  );

  static TextStyle get gameButton => GoogleFonts.poppins(
    fontSize: fontSizeL,
    fontWeight: semiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWide,
  );
}
