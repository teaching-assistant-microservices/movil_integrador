import 'package:go_router/go_router.dart';
import 'package:integrador/core/router/routes.dart';
import 'package:integrador/features/auth/ui/providers/auth_provider.dart';

// AUTH
import 'package:integrador/features/auth/ui/screens/login_screen.dart';
import 'package:integrador/features/auth/ui/screens/register_screen.dart';

// MAIN NAVIGATION
import 'package:integrador/features/home/ui/screens/home_screen.dart';
import 'package:integrador/features/assistant/ui/screens/assistant_screen.dart';
import 'package:integrador/features/explore/ui/screens/explore_screen.dart';
import 'package:integrador/features/analysis/ui/screens/analysis_screen.dart';
import 'package:integrador/features/profile/ui/screens/profile_screen.dart';

// DOCUMENTS
import 'package:integrador/features/document/ui/screens/upload_document_screen.dart';
import 'package:integrador/features/document/ui/screens/document_detail_screen.dart';

// REPORTS
import 'package:integrador/features/reports/ui/screens/generate_report_screen.dart';

// SETTINGS
import 'package:integrador/features/settings/ui/screens/settings_screen.dart';

class AppRouter {
  final AuthProvider authProvider;

  AppRouter(this.authProvider);

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.loginPath,
    refreshListenable: authProvider,
    redirect: (context, state) {
      final bool isAuth = authProvider.isAuthenticated;
      final String loc = state.matchedLocation;

      final bool isAuthRoute =
          loc == AppRoutes.loginPath || loc == AppRoutes.registerPath;

      if (!isAuth && !isAuthRoute) {
        return AppRoutes.loginPath;
      }

      if (isAuth && isAuthRoute) {
        return AppRoutes.homePath;
      }

      return null;
    },
    routes: [
      // ===================== AUTH ROUTES =====================
      GoRoute(
        path: AppRoutes.loginPath,
        name: AppRoutes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.registerPath,
        name: AppRoutes.register,
        builder: (_, __) => const RegisterScreen(),
      ),

      // ===================== MAIN NAVIGATION =====================
      GoRoute(
        path: AppRoutes.homePath, // Es '/home'
        name: AppRoutes.home,
        builder: (_, __) => const HomeScreen(),
        routes: [
          // RUTA ANIDADA (HIJA)
          // Al estar dentro de home, GoRouter concatena las rutas.
          // Resultado final: /home/upload
          GoRoute(
            path: 'upload', // NO debe tener '/' al principio
            name: AppRoutes.uploadDocument,
            builder: (_, __) => const UploadDocumentScreen(),
          ),
        ],
      ),

      GoRoute(
        path: AppRoutes.assistantPath,
        name: AppRoutes.assistant,
        builder: (_, __) => const AssistantScreen(),
      ),
      GoRoute(
        path: AppRoutes.explorePath,
        name: AppRoutes.explore,
        builder: (_, __) => const ExploreScreen(),
      ),
      GoRoute(
        path: AppRoutes.analysisPath,
        name: AppRoutes.analysis,
        builder: (_, __) => const AnalysisScreen(),
      ),
      GoRoute(
        path: AppRoutes.profilePath,
        name: AppRoutes.profile,
        builder: (_, __) => const ProfileScreen(),
      ),

      // ===================== DOCUMENT ROUTES =====================
      GoRoute(
        path: '/documents/:documentId',
        name: AppRoutes.documentDetail,
        builder: (_, state) {
          final id = state.pathParameters['documentId']!;
          return DocumentDetailScreen(documentId: id);
        },
      ),

      // ===================== REPORTS ROUTES =====================
      GoRoute(
        path: AppRoutes.generateReportPath,
        name: AppRoutes.generateReport,
        builder: (_, __) => const GenerateReportScreen(),
      ),

      // ===================== SETTINGS ROUTES =====================
      GoRoute(
        path: AppRoutes.settingsPath,
        name: AppRoutes.settings,
        builder: (_, __) => const SettingsScreen(),
      ),
    ],
  );
}
