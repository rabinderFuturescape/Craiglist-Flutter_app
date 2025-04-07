import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

/// A standardized card component
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double elevation;
  final double borderRadius;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final bool hasBorder;
  final Color? borderColor;

  const AppCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    this.elevation = 2,
    this.borderRadius = 12,
    this.backgroundColor,
    this.onTap,
    this.hasBorder = false,
    this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final defaultBorderColor = isDarkMode ? AppColors.borderDark : AppColors.border;
    final defaultBackgroundColor = isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight;
    
    final card = Card(
      margin: margin,
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: hasBorder
            ? BorderSide(
                color: borderColor ?? defaultBorderColor,
                width: 1,
              )
            : BorderSide.none,
      ),
      color: backgroundColor ?? defaultBackgroundColor,
      child: Padding(
        padding: padding,
        child: child,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: card,
      );
    }

    return card;
  }
}
