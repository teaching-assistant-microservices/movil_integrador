// lib/features/profile/ui/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:integrador/common/widgets/widgets.dart';
import 'package:integrador/themes/app_theme.dart';
import 'package:integrador/core/router/routes.dart';
import 'package:integrador/core/config/app_config.dart';
import 'package:integrador/features/auth/ui/providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              await context.read<AuthProvider>().logout();

              if (context.mounted) {
                context.go(AppRoutes.loginPath);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Perfil',
      currentNavIndex: 4,
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // User Info Card
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppTheme.primaryColor,
                          child: Text(
                            user?.name.substring(0, 1).toUpperCase() ?? 'U',
                            style: const TextStyle(
                              fontSize: 40,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Name
                        Text(
                          user?.name ?? 'Usuario',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),

                        const SizedBox(height: 8),

                        // Email
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.email_outlined,
                              size: 16,
                              color: AppTheme.textSecondaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              user?.email ?? '',
                              style: TextStyle(
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // User ID Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'ID: ${user?.id ?? ''}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.primaryColor,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Settings Options
                _SettingsOption(
                  icon: Icons.settings_outlined,
                  title: 'Configuración',
                  subtitle: 'Ajustes de la aplicación',
                  onTap: () => context.go(AppRoutes.settingsPath),
                ),

                _SettingsOption(
                  icon: Icons.tune_outlined,
                  title: 'Preferencias',
                  subtitle: 'Personaliza tu experiencia',
                  onTap: () => context.go(AppRoutes.preferencesPath),
                ),

                _SettingsOption(
                  icon: Icons.help_outline,
                  title: 'Ayuda y Soporte',
                  subtitle: '¿Necesitas ayuda?',
                  onTap: () => context.go(AppRoutes.helpPath),
                ),

                const SizedBox(height: 16),

                // App Info Card
                Card(
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Información de la App',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(label: 'Versión', value: '1.0.0'),
                        _InfoRow(
                          label: 'Modo',
                          value: AppConfig.useMockData ? 'Mock' : 'Producción',
                        ),
                        _InfoRow(
                          label: 'API Gateway',
                          value: AppConfig.apiGatewayBaseUrl,
                        ),
                        _InfoRow(
                          label: 'Core IA',
                          value: AppConfig.coreAIBaseUrl,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showLogoutDialog(context),
                    icon: const Icon(Icons.logout),
                    label: const Text('Cerrar Sesión'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.errorColor,
                      side: const BorderSide(color: AppTheme.errorColor),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SettingsOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: AppTheme.textSecondaryColor, fontSize: 14),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
