import 'package:flutter/material.dart';

class Tailwind {
  // Spacing
  static const double spacing1 = 4.0;
  static const double spacing2 = 8.0;
  static const double spacing3 = 12.0;
  static const double spacing4 = 16.0;
  static const double spacing5 = 20.0;
  static const double spacing6 = 24.0;
  static const double spacing8 = 32.0;
  static const double spacing10 = 40.0;
  static const double spacing12 = 48.0;
  static const double spacing16 = 64.0;

  // Border Radius
  static final BorderRadius borderRadiusSm = BorderRadius.circular(4);
  static final BorderRadius borderRadiusLg = BorderRadius.circular(8);

  // Shadows
  static List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];
  static List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];
  static List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  // Text Styles
  static TextStyle textXs(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall ?? const TextStyle(fontSize: 12);
  static TextStyle textSm(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 14);
  static TextStyle textBase(BuildContext context) =>
      Theme.of(context).textTheme.bodyLarge ?? const TextStyle(fontSize: 16);
  static TextStyle textLg(BuildContext context) =>
      Theme.of(context).textTheme.titleMedium ?? const TextStyle(fontSize: 18);
  static TextStyle textXl(BuildContext context) =>
      Theme.of(context).textTheme.titleLarge ?? const TextStyle(fontSize: 20);
  static TextStyle text2xl(BuildContext context) =>
      Theme.of(context).textTheme.headlineSmall!;

  // Colors
  static Color primary(BuildContext context) =>
      Theme.of(context).colorScheme.primary;
  static Color secondary(BuildContext context) =>
      Theme.of(context).colorScheme.secondary;
  static Color surface(BuildContext context) =>
      Theme.of(context).colorScheme.surface;
  static Color background(BuildContext context) =>
      Theme.of(context).colorScheme.surface;
  static Color error(BuildContext context) =>
      Theme.of(context).colorScheme.error;
  static Color onPrimary(BuildContext context) =>
      Theme.of(context).colorScheme.onPrimary;
  static Color onSecondary(BuildContext context) =>
      Theme.of(context).colorScheme.onSecondary;
  static Color onSurface(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;
  static Color onBackground(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;
  static Color onError(BuildContext context) =>
      Theme.of(context).colorScheme.onError;

  // Gradients
  static LinearGradient gradientPrimary(BuildContext context) => LinearGradient(
        colors: [
          primary(context),
          primary(context).withOpacity(0.8),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // Container Styles
  static BoxDecoration cardDecoration(BuildContext context) => BoxDecoration(
        color: surface(context),
        borderRadius: borderRadiusLg,
        boxShadow: [
          BoxShadow(
            color: onSurface(context).withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      );

  static BoxDecoration buttonDecoration(BuildContext context) => BoxDecoration(
        gradient: gradientPrimary(context),
        borderRadius: borderRadiusSm,
        boxShadow: shadowSm,
      );
}
