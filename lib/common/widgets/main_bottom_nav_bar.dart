import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:integrador/core/router/routes.dart';
import 'package:integrador/themes/app_theme.dart';

class MainBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const MainBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  void _onItemTapped(BuildContext context, int index) {
    // Evitar navegación si ya estamos en la pantalla actual
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        context.go(AppRoutes.homePath);
        break;
      case 1:
        context.go(AppRoutes.assistantPath);
        break;
      case 2:
        context.go(AppRoutes.explorePath);
        break;
      case 3:
        context.go(AppRoutes.analysisPath);
        break;
      case 4:
        context.go(AppRoutes.profilePath);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _onItemTapped(context, index),
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: AppTheme.primaryColor,
      unselectedItemColor: AppTheme.textSecondaryColor,
      selectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          activeIcon: Icon(Icons.chat_bubble),
          label: 'Asistente',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.explore_outlined),
          activeIcon: Icon(Icons.explore),
          label: 'Explorar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics_outlined),
          activeIcon: Icon(Icons.analytics),
          label: 'Análisis',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    );
  }
}
