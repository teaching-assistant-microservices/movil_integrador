import 'package:flutter/material.dart';
import 'package:integrador/features/home/ui/providers/home_provider.dart';
import 'package:provider/provider.dart';

import 'package:integrador/features/assistant/ui/providers/assistant_provider.dart';
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

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AssistantProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
       
      ],
      child: MaterialApp.router(
        title: 'Asistente Pedagógico Inteligente',
        debugShowCheckedModeBanner: false,

        // Temas
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,

        // Router
        routerConfig: appRouter.router,
      ),
    );
  }
}
