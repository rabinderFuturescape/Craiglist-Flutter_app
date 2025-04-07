import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/text_styles.dart';

/// A standardized app bar component
class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final bool automaticallyImplyLeading;
  final double elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final PreferredSizeWidget? bottom;
  final Widget? flexibleSpace;
  final int? titleMaxLines;
  final TextOverflow titleOverflow;

  const AppBarWidget({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.automaticallyImplyLeading = true,
    this.elevation = 0,
    this.backgroundColor,
    this.foregroundColor,
    this.bottom,
    this.flexibleSpace,
    this.titleMaxLines,
    this.titleOverflow = TextOverflow.ellipsis,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final defaultBackgroundColor = isDarkMode ? AppColors.surfaceDark : AppColors.primary;
    final defaultForegroundColor = isDarkMode ? Colors.white : Colors.white;

    return AppBar(
      title: Text(
        title,
        style: AppTextStyles.headline6.copyWith(
          color: foregroundColor ?? defaultForegroundColor,
        ),
        maxLines: titleMaxLines,
        overflow: titleOverflow,
      ),
      actions: actions,
      leading: leading,
      centerTitle: centerTitle,
      automaticallyImplyLeading: automaticallyImplyLeading,
      elevation: elevation,
      backgroundColor: backgroundColor ?? defaultBackgroundColor,
      foregroundColor: foregroundColor ?? defaultForegroundColor,
      bottom: bottom,
      flexibleSpace: flexibleSpace,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(bottom != null ? kToolbarHeight + bottom!.preferredSize.height : kToolbarHeight);
}
