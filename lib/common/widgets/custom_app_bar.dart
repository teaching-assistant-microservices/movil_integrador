import 'package:flutter/material.dart';
import 'package:integrador/themes/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textPrimaryColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: Colors.white,
      foregroundColor: AppTheme.textPrimaryColor,
      elevation: 0,
      leading: leading,
      actions: actions,
      bottom: bottom,
      iconTheme: const IconThemeData(
        color: AppTheme.textPrimaryColor,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );
}
