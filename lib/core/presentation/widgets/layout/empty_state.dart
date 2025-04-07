import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/text_styles.dart';
import '../buttons/primary_button.dart';

/// A standardized empty state widget
class EmptyState extends StatelessWidget {
  final String message;
  final String? buttonText;
  final VoidCallback? onAction;
  final IconData icon;
  final double iconSize;

  const EmptyState({
    Key? key,
    required this.message,
    this.buttonText,
    this.onAction,
    this.icon = Icons.inbox_outlined,
    this.iconSize = 64.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final textColor = isDarkMode ? Colors.white : AppColors.textPrimary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: iconColor,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTextStyles.body1.copyWith(color: textColor),
              textAlign: TextAlign.center,
            ),
            if (onAction != null && buttonText != null) ...[
              const SizedBox(height: 24),
              PrimaryButton(
                text: buttonText!,
                onPressed: onAction,
                isFullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
