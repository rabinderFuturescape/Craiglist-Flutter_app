import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

/// A secondary button with standardized styling
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final double? width;
  final double height;
  final EdgeInsets padding;
  final double borderRadius;

  const SecondaryButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.width,
    this.height = 48.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
    this.borderRadius = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final buttonColor = isDarkMode ? AppColors.primaryDark : AppColors.primary;
    
    final buttonStyle = OutlinedButton.styleFrom(
      padding: padding,
      minimumSize: Size(isFullWidth ? double.infinity : (width ?? 120), height),
      side: BorderSide(color: buttonColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );

    Widget buttonContent;
    if (isLoading) {
      buttonContent = SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          color: buttonColor,
          strokeWidth: 2.0,
        ),
      );
    } else if (icon != null) {
      buttonContent = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    } else {
      buttonContent = Text(text);
    }

    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: buttonStyle,
      child: buttonContent,
    );
  }
}
