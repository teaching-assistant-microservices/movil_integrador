// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:integrador/features/auth/ui/providers/auth_provider.dart';
import 'package:integrador/features/assistant/ui/providers/assistant_provider.dart';
import 'package:integrador/features/home/ui/providers/home_provider.dart';
import 'package:integrador/core/router/app_router.dart';
import 'package:integrador/themes/app_theme.dart';
import 'package:integrador/core/config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar cualquier configuración necesaria
  AppConfig.debugLog('Iniciando aplicación...');
  AppConfig.debugLog('Modo Mock: ${AppConfig.useMockData}');
  AppConfig.debugLog('API Gateway: ${AppConfig.apiGatewayBaseUrl}');
  AppConfig.debugLog('Core IA: ${AppConfig.coreAIBaseUrl}');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Provider (debe ser el primero)
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),

        // Home Provider
        ChangeNotifierProvider(create: (_) => HomeProvider()),

        // Assistant Provider
        ChangeNotifierProvider(create: (_) => AssistantProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final appRouter = AppRouter(authProvider);

          return MaterialApp.router(
            title: 'Asistente Pedagógico Inteligente',
            debugShowCheckedModeBanner: false,

            // Temas
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,

            // Router
            routerConfig: appRouter.router,
          );
        },
      ),
    );
  }
}
