import 'package:flutter/material.dart';
import 'package:integrador/common/widgets/custom_app_bar.dart';
import 'package:integrador/common/widgets/main_bottom_nav_bar.dart';
import 'package:integrador/themes/app_theme.dart';

/// Scaffold principal que envuelve las pantallas principales de la app
/// con AppBar y BottomNavigationBar consistentes
class MainScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final int currentNavIndex;
  final List<Widget>? actions;
  final Widget? leading;
  final FloatingActionButton? floatingActionButton;
  final PreferredSizeWidget? bottom;
  final bool showBottomNav;
  final bool showAppBar;

  const MainScaffold({
    super.key,
    required this.title,
    required this.body,
    required this.currentNavIndex,
    this.actions,
    this.leading,
    this.floatingActionButton,
    this.bottom,
    this.showBottomNav = true,
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: showAppBar
          ? CustomAppBar(
              title: title,
              actions: actions,
              leading: leading,
              bottom: bottom,
            )
          : null,
      body: body,
      bottomNavigationBar: showBottomNav
          ? MainBottomNavBar(currentIndex: currentNavIndex)
          : null,
      floatingActionButton: floatingActionButton,
    );
  }
}
