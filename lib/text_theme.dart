import 'package:flutter/material.dart';
import 'package:material_widgets/material_widgets.dart';
import 'package:google_fonts/google_fonts.dart';

typedef _BaseStyleFactory = TextStyle Function({
  FontWeight? fontWeight,
  double? letterSpacing,
});

MD3TextAdaptativeTheme _fromGoogleFonts({
  _BaseStyleFactory? fontFamily,
  _BaseStyleFactory? brandRegularFontFamily,
  _BaseStyleFactory? plainMediumFontFamily,
}) {
  assert(fontFamily != null
      ? (plainMediumFontFamily == brandRegularFontFamily &&
          brandRegularFontFamily == null)
      : true);
  const baseline = MD3TextAdaptativeTheme.baseline;
  return MD3TextAdaptativeTheme(
    displayLarge: MD3TextStyle(
      base: (brandRegularFontFamily ?? fontFamily)?.call(
            fontWeight: FontWeight.w400,
            letterSpacing: 0,
          ) ??
          baseline.displayLarge.base,
      scale: baseline.displayLarge.scale,
    ),
    displayMedium: MD3TextStyle(
      base: (brandRegularFontFamily ?? fontFamily)?.call(
            fontWeight: FontWeight.w400,
            letterSpacing: 0,
          ) ??
          baseline.displayMedium.base,
      scale: baseline.displayMedium.scale,
    ),
    displaySmall: MD3TextStyle(
      base: (brandRegularFontFamily ?? fontFamily)?.call(
            fontWeight: FontWeight.w400,
            letterSpacing: 0,
          ) ??
          baseline.displaySmall.base,
      scale: baseline.displaySmall.scale,
    ),
    headlineLarge: MD3TextStyle(
      base: (brandRegularFontFamily ?? fontFamily)?.call(
            fontWeight: FontWeight.w400,
            letterSpacing: 0,
          ) ??
          baseline.headlineLarge.base,
      scale: baseline.headlineLarge.scale,
    ),
    headlineMedium: MD3TextStyle(
      base: (brandRegularFontFamily ?? fontFamily)?.call(
            fontWeight: FontWeight.w400,
            letterSpacing: 0,
          ) ??
          baseline.headlineMedium.base,
      scale: baseline.headlineMedium.scale,
    ),
    headlineSmall: MD3TextStyle(
      base: (brandRegularFontFamily ?? fontFamily)?.call(
            fontWeight: FontWeight.w400,
            letterSpacing: 0,
          ) ??
          baseline.headlineSmall.base,
      scale: baseline.headlineSmall.scale,
    ),
    titleLarge: MD3TextStyle(
      base: (brandRegularFontFamily ?? fontFamily)?.call(
            fontWeight: FontWeight.w400,
            letterSpacing: 0,
          ) ??
          baseline.titleLarge.base,
      scale: baseline.titleLarge.scale,
    ),
    titleMedium: MD3TextStyle(
      base: (plainMediumFontFamily ?? fontFamily)?.call(
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ) ??
          baseline.titleMedium.base,
      scale: baseline.titleMedium.scale,
    ),
    titleSmall: MD3TextStyle(
      base: (plainMediumFontFamily ?? fontFamily)?.call(
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ) ??
          baseline.titleSmall.base,
      scale: baseline.titleSmall.scale,
    ),
    labelLarge: MD3TextStyle(
      base: (plainMediumFontFamily ?? fontFamily)?.call(
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ) ??
          baseline.labelLarge.base,
      scale: baseline.labelLarge.scale,
    ),
    labelMedium: MD3TextStyle(
      base: (plainMediumFontFamily ?? fontFamily)?.call(
            fontWeight: FontWeight.w500,
            letterSpacing: 0.4,
          ) ??
          baseline.labelMedium.base,
      scale: baseline.labelMedium.scale,
    ),
    labelSmall: MD3TextStyle(
      base: (plainMediumFontFamily ?? fontFamily)?.call(
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ) ??
          baseline.labelSmall.base,
      scale: baseline.labelSmall.scale,
    ),
    bodyLarge: MD3TextStyle(
      base: (plainMediumFontFamily ?? fontFamily)?.call(
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ) ??
          baseline.bodyLarge.base,
      scale: baseline.bodyLarge.scale,
    ),
    bodyMedium: MD3TextStyle(
      base: (plainMediumFontFamily ?? fontFamily)?.call(
            fontWeight: FontWeight.w500,
            letterSpacing: 0.25,
          ) ??
          baseline.bodyMedium.base,
      scale: baseline.bodyMedium.scale,
    ),
    bodySmall: MD3TextStyle(
      base: (plainMediumFontFamily ?? fontFamily)?.call(
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ) ??
          baseline.bodySmall.base,
      scale: baseline.bodySmall.scale,
    ),
  );
}

final MD3TextAdaptativeTheme textTheme = _fromGoogleFonts(
  brandRegularFontFamily: GoogleFonts.atkinsonHyperlegible,
  plainMediumFontFamily: GoogleFonts.roboto,
);
