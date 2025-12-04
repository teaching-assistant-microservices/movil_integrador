// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:integrador/core/router/routes.dart';
import 'package:integrador/features/auth/ui/providers/auth_provider.dart';

// Auth Screens
import 'package:integrador/features/auth/ui/screens/login_screen.dart';
import 'package:integrador/features/auth/ui/screens/register_screen.dart';

// Main Navigation Screens
import 'package:integrador/features/home/ui/screens/home_screen.dart';
import 'package:integrador/features/assistant/ui/screens/assistant_screen.dart';
import 'package:integrador/features/explore/ui/screens/explore_screen.dart';
import 'package:integrador/features/analysis/ui/screens/analysis_screen.dart';
import 'package:integrador/features/profile/ui/screens/profile_screen.dart';

// Document Screens
import 'package:integrador/features/documents/ui/screens/upload_document_screen.dart';
import 'package:integrador/features/documents/ui/screens/document_detail_screen.dart';

// Grouping Screens
import 'package:integrador/features/groupings/ui/screens/grouping_detail_screen.dart';
import 'package:integrador/features/groupings/ui/screens/recommendations_screen.dart';

// Report Screens
import 'package:integrador/features/reports/ui/screens/report_preview_screen.dart';
import 'package:integrador/features/reports/ui/screens/generate_report_screen.dart';

// Settings Screens
import 'package:integrador/features/settings/ui/screens/settings_screen.dart';
import 'package:integrador/features/settings/ui/screens/preferences_screen.dart';
import 'package:integrador/features/settings/ui/screens/help_screen.dart';

class AppRouter {
  final AuthProvider authProvider;

  AppRouter(this.authProvider);

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.loginPath,
    refreshListenable: authProvider, // Escucha cambios en autenticación
    redirect: (BuildContext context, GoRouterState state) {
      final isAuthenticated = authProvider.isAuthenticated;
      final isAuthRoute =
          state.matchedLocation == AppRoutes.loginPath ||
          state.matchedLocation == AppRoutes.registerPath;

      // Si no está autenticado y no está en ruta de auth, redirigir a login
      if (!isAuthenticated && !isAuthRoute) {
        return AppRoutes.loginPath;
      }

      // Si está autenticado y está en ruta de auth, redirigir a home
      if (isAuthenticated && isAuthRoute) {
        return AppRoutes.homePath;
      }

      // No redirigir
      return null;
    },
    routes: [
      // ============ AUTH ROUTES (Públicas) ============
      GoRoute(
        path: AppRoutes.loginPath,
        name: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: AppRoutes.registerPath,
        name: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),

      // ============ MAIN NAVIGATION ROUTES (Protegidas) ============
      GoRoute(
        path: AppRoutes.homePath,
        name: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'upload',
            name: AppRoutes.uploadDocument,
            builder: (context, state) => const UploadDocumentScreen(),
          ),
        ],
      ),

      GoRoute(
        path: AppRoutes.assistantPath,
        name: AppRoutes.assistant,
        builder: (context, state) => const AssistantScreen(),
      ),

      GoRoute(
        path: AppRoutes.explorePath,
        name: AppRoutes.explore,
        builder: (context, state) => const ExploreScreen(),
      ),

      GoRoute(
        path: AppRoutes.analysisPath,
        name: AppRoutes.analysis,
        builder: (context, state) => const AnalysisScreen(),
      ),

      GoRoute(
        path: AppRoutes.profilePath,
        name: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),

      // ============ DOCUMENT ROUTES ============
      GoRoute(
        path: AppRoutes.documentDetailPath,
        name: AppRoutes.documentDetail,
        builder: (context, state) {
          final documentId = state.pathParameters['documentId']!;
          return DocumentDetailScreen(documentId: documentId);
        },
      ),

      // ============ GROUPING ROUTES ============
      GoRoute(
        path: AppRoutes.groupingDetailPath,
        name: AppRoutes.groupingDetail,
        builder: (context, state) {
          final groupingId = state.pathParameters['groupingId']!;
          return GroupingDetailScreen(groupingId: groupingId);
        },
        routes: [
          GoRoute(
            path: 'recommendations',
            name: AppRoutes.recommendations,
            builder: (context, state) {
              final groupingId = state.pathParameters['groupingId']!;
              return RecommendationsScreen(groupingId: groupingId);
            },
          ),
        ],
      ),

      // ============ REPORT ROUTES ============
      GoRoute(
        path: AppRoutes.reportPreviewPath,
        name: AppRoutes.reportPreview,
        builder: (context, state) {
          final reportId = state.pathParameters['reportId']!;
          return ReportPreviewScreen(reportId: reportId);
        },
      ),

      GoRoute(
        path: AppRoutes.generateReportPath,
        name: AppRoutes.generateReport,
        builder: (context, state) => const GenerateReportScreen(),
      ),

      // ============ SETTINGS ROUTES ============
      GoRoute(
        path: AppRoutes.settingsPath,
        name: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'preferences',
            name: AppRoutes.preferences,
            builder: (context, state) => const PreferencesScreen(),
          ),
          GoRoute(
            path: 'help',
            name: AppRoutes.help,
            builder: (context, state) => const HelpScreen(),
          ),
        ],
      ),
    ],
  );
}
