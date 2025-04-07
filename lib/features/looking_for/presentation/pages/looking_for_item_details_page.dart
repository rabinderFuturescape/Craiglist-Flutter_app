import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/presentation/widgets/layout/app_bar_widget.dart';
import '../../../../core/presentation/widgets/buttons/primary_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../domain/entities/looking_for_item.dart';

/// Page to display the details of a "Looking For" item
class LookingForItemDetailsPage extends StatelessWidget {
  final LookingForItem item;

  const LookingForItemDetailsPage({
    Key? key,
    required this.item,
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
    
    return Scaffold(
      appBar: AppBarWidget(
        title: 'Looking For Details',
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share functionality would be implemented here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Share functionality coming soon'),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and budget
            Text(
              item.title,
              style: AppTextStyles.headline6.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // Budget
            Row(
              children: [
                Icon(
                  Icons.attach_money,
                  size: 20,
                  color: isDarkMode ? AppColors.primaryDark : AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Budget: \$${item.maxBudget.toStringAsFixed(2)}',
                  style: AppTextStyles.subtitle1.copyWith(
                    color: isDarkMode ? AppColors.primaryDark : AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Expiry date
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 20,
                  color: isExpired
                      ? AppColors.error
                      : isExpiringSoon
                          ? AppColors.warning
                          : secondaryTextColor,
                ),
                const SizedBox(width: 4),
                Text(
                  isExpired
                      ? 'Expired on ${_formatDate(item.expiryDate)}'
                      : 'Expires on ${_formatDate(item.expiryDate)} (${daysRemaining} days left)',
                  style: AppTextStyles.body2.copyWith(
                    color: isExpired
                        ? AppColors.error
                        : isExpiringSoon
                            ? AppColors.warning
                            : secondaryTextColor,
                    fontWeight: isExpired || isExpiringSoon ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Location
            if (item.location != null)
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 20,
                    color: secondaryTextColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    item.location!,
                    style: AppTextStyles.body2.copyWith(
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 24),
            
            // Description section
            Text(
              'Description',
              style: AppTextStyles.subtitle1.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.description,
              style: AppTextStyles.body1.copyWith(
                color: textColor,
              ),
            ),
            const SizedBox(height: 24),
            
            // Categories section
            Text(
              'Categories',
              style: AppTextStyles.subtitle1.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: item.categories.map((category) => _buildTag(context, category)).toList(),
            ),
            const SizedBox(height: 24),
            
            // Preferred conditions section
            if (item.preferredConditions != null && item.preferredConditions!.isNotEmpty) ...[
              Text(
                'Preferred Conditions',
                style: AppTextStyles.subtitle1.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: item.preferredConditions!
                    .map((condition) => _buildTag(context, condition))
                    .toList(),
              ),
              const SizedBox(height: 24),
            ],
            
            // Contact information section
            Text(
              'Contact Information',
              style: AppTextStyles.subtitle1.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              color: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isDarkMode ? AppColors.borderDark : AppColors.border,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: isDarkMode ? AppColors.primaryDark : AppColors.primary,
                          child: Text(
                            item.userName.isNotEmpty ? item.userName[0].toUpperCase() : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.userName,
                              style: AppTextStyles.subtitle2.copyWith(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (item.contactInfo != null)
                              Text(
                                item.contactInfo!,
                                style: AppTextStyles.body2.copyWith(
                                  color: secondaryTextColor,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      text: 'Contact Buyer',
                      icon: Icons.message,
                      onPressed: () => _contactBuyer(context),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Format a date to a readable string
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Build a tag widget for a category or condition
  Widget _buildTag(BuildContext context, String text) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

  /// Contact the buyer
  void _contactBuyer(BuildContext context) async {
    if (item.contactInfo != null && item.contactInfo!.contains('@')) {
      // If contact info is an email, open email app
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: item.contactInfo,
        queryParameters: {
          'subject': 'Regarding your request: ${item.title}',
          'body': 'Hello ${item.userName},\n\nI saw your request for "${item.title}" and I think I can help.\n\n',
        },
      );
      
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open email app'),
            ),
          );
        }
      }
    } else if (item.contactInfo != null && item.contactInfo!.contains(RegExp(r'^\+?[0-9\s\-\(\)]{10,15}$'))) {
      // If contact info is a phone number, open phone app
      final Uri telUri = Uri(
        scheme: 'tel',
        path: item.contactInfo,
      );
      
      if (await canLaunchUrl(telUri)) {
        await launchUrl(telUri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open phone app'),
            ),
          );
        }
      }
    } else {
      // Otherwise, show a dialog with contact info
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Contact Information'),
            content: Text(
              item.contactInfo ?? 'No contact information provided',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    }
  }
}
