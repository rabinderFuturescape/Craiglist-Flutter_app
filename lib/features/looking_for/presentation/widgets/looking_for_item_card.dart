import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/cards/app_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../domain/entities/looking_for_item.dart';
import '../pages/looking_for_item_details_page.dart';

/// A card widget to display a "Looking For" item in a list
class LookingForItemCard extends StatelessWidget {
  final LookingForItem item;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const LookingForItemCard({
    Key? key,
    required this.item,
    this.onDelete,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : AppColors.textPrimary;
    final secondaryTextColor = isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary;
    
    // Calculate days remaining until expiry
    final daysRemaining = item.expiryDate.difference(DateTime.now()).inDays;
    final isExpiringSoon = daysRemaining <= 3 && daysRemaining > 0;
    final isExpired = item.isExpired;
    
    return AppCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and budget
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: AppTextStyles.subtitle1.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                'Budget: \$${item.maxBudget.toStringAsFixed(2)}',
                style: AppTextStyles.subtitle2.copyWith(
                  color: isDarkMode ? AppColors.primaryDark : AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Description
          Text(
            item.description,
            style: AppTextStyles.body2.copyWith(color: secondaryTextColor),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          
          // Categories
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: item.categories.map((category) => _buildTag(context, category)).toList(),
          ),
          const SizedBox(height: 12),
          
          // Expiry date and actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Expiry status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isExpired
                      ? AppColors.error.withAlpha(51)
                      : isExpiringSoon
                          ? AppColors.warning.withAlpha(51)
                          : AppColors.success.withAlpha(51),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isExpired
                      ? 'Expired'
                      : isExpiringSoon
                          ? '$daysRemaining days left'
                          : 'Active',
                  style: AppTextStyles.caption.copyWith(
                    color: isExpired
                        ? AppColors.error
                        : isExpiringSoon
                            ? AppColors.warning
                            : AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              // Actions
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LookingForItemDetailsPage(item: item),
                        ),
                      );
                    },
                    child: Text(
                      'View Details',
                      style: AppTextStyles.button.copyWith(
                        color: isDarkMode ? AppColors.primaryDark : AppColors.primary,
                      ),
                    ),
                  ),
                  if (onEdit != null)
                    IconButton(
                      icon: const Icon(Icons.edit, size: 18),
                      onPressed: onEdit,
                      color: secondaryTextColor,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete, size: 18),
                      onPressed: onDelete,
                      color: AppColors.error,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build a tag widget for a category
  Widget _buildTag(BuildContext context, String text) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark.withAlpha(150) : AppColors.surfaceLight.withAlpha(200),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? AppColors.borderDark : AppColors.border,
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary,
        ),
      ),
    );
  }
}
