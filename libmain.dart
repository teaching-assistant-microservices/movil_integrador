import 'package:flutter/material.dart';
import 'package:integrador/core/router/app_router.dart';
import 'package:integrador/themes/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = AppRouter();

    return MaterialApp.router(
      title: 'Asistente Pedagógico Inteligente',
      debugShowCheckedModeBanner: false,

      // Tema claro y oscuro
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,

      // Configuración del router
      routerConfig: appRouter.router,
    );
  }
}
