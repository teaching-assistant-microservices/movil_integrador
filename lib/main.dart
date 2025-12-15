// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/config/app_config.dart';
import 'core/router/app_router.dart';
import 'core/utils/logger.dart';

// Providers
import 'features/auth/ui/providers/auth_provider.dart';
import 'features/assistant/ui/providers/assistant_provider.dart';
import 'features/document/ui/providers/documents_provider.dart';
import 'features/profile/ui/providers/profile_provider.dart';
import 'features/home/ui/providers/files_provider.dart';

import 'injection_container.dart' as di;
import 'themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 CRÍTICO: Inicializar dependencias ANTES de runApp
  await di.init();

  // Logs de inicialización
  AppLogger.separator(label: 'APLICACIÓN INICIADA');
  AppConfig.debugLog('✅ Aplicación iniciada');
  AppConfig.debugLog('📦 Modo Mock: ${AppConfig.useMockData}');
  AppConfig.debugLog('🌐 API Gateway: ${AppConfig.apiGatewayBaseUrl}');
  AppConfig.debugLog('🤖 Core IA: ${AppConfig.coreAIBaseUrl}');
  AppConfig.debugLog('🔧 Debug Logs: ${AppConfig.enableDebugLogs}');
  AppLogger.separator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔥 MultiProvider con TODOS los providers
    return MultiProvider(
      providers: [
        // ========================================
        // AUTH PROVIDER (con inicialización automática)
        // ========================================
        ChangeNotifierProvider(
          create: (_) {
            AppLogger.info('🔐 Inicializando AuthProvider', tag: 'App');
            return di.sl<AuthProvider>()..initialize();
          },
        ),

        // ========================================
        // ASSISTANT PROVIDER
        // ========================================
        ChangeNotifierProvider(
          create: (_) {
            AppLogger.info('💬 Inicializando AssistantProvider', tag: 'App');
            return di.sl<AssistantProvider>();
          },
        ),

        // ========================================
        // DOCUMENTS PROVIDER (con carga automática)
        // ========================================
        ChangeNotifierProvider(
          create: (_) {
            AppLogger.info('📄 Inicializando DocumentsProvider', tag: 'App');
            final provider = di.sl<DocumentsProvider>();
            // Cargar documentos al iniciar la app
            provider.loadDocuments();
            return provider;
          },
        ),

        // ========================================
        // PROFILE PROVIDER (con inicialización automática)
        // ========================================
        ChangeNotifierProvider(
          create: (_) {
            AppLogger.info('👤 Inicializando ProfileProvider', tag: 'App');
            return di.sl<ProfileProvider>()..initialize();
          },
        ),

        // ========================================
        // FILES PROVIDER (Home Screen)
        // ========================================
        ChangeNotifierProvider(
          create: (_) {
            AppLogger.info('📂 Inicializando FilesProvider', tag: 'App');
            return di.sl<FilesProvider>();
          },
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          // Crear router con el authProvider para manejar redirects
          final appRouter = AppRouter(authProvider);

          return MaterialApp.router(
            // ========================================
            // APP CONFIGURATION
            // ========================================
            title: 'Asistente Pedagógico Inteligente',
            debugShowCheckedModeBanner: false,

            // ========================================
            // THEMES (Material You)
            // ========================================
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,

            // ========================================
            // ROUTER (Go Router con navegación declarativa)
            // ========================================
            routerConfig: appRouter.router,

            // ========================================
            // BUILDER (para logging de navegación)
            // ========================================
            builder: (context, child) {
              // Log de navegación si está habilitado
              if (AppConfig.enableDebugLogs) {
                _logNavigationState(context);
              }
              return child ?? const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }

  /// Log del estado de navegación (útil para debugging)
  void _logNavigationState(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentRoute = ModalRoute.of(context)?.settings.name;
      if (currentRoute != null) {
        AppLogger.debug(
          'Navegación actual',
          tag: 'Router',
          data: {'route': currentRoute},
        );
      }
    });
  }
}

// ========================================
// ERROR WIDGET PERSONALIZADO (OPCIONAL)
// ========================================
class CustomErrorWidget extends StatelessWidget {
  final FlutterErrorDetails errorDetails;

  const CustomErrorWidget({super.key, required this.errorDetails});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppTheme.errorColor,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Algo salió mal',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (AppConfig.enableDebugLogs)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        errorDetails.exception.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ========================================
// CONFIGURAR ERROR WIDGET (Opcional)
// ========================================
// Descomentar para usar custom error widget:
/*
void _configureErrorWidget() {
  ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
    return CustomErrorWidget(errorDetails: errorDetails);
  };
}
*/
