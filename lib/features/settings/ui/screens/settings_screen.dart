// ========================================
// PANTALLA 6: SettingsScreen
// lib/features/settings/ui/screens/settings_screen.dart
// ========================================
import 'package:flutter/material.dart';
import 'package:integrador/common/widgets/detail_scaffold.dart';
import 'package:integrador/themes/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DetailScaffold(
      title: 'Configuración',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            context,
            title: 'General',
            children: [
              _buildSettingTile(
                context,
                icon: Icons.language,
                title: 'Idioma',
                subtitle: 'Español',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              _buildSettingTile(
                context,
                icon: Icons.notifications_outlined,
                title: 'Notificaciones',
                subtitle: 'Gestionar alertas',
                trailing: Switch(value: true, onChanged: (_) {}),
                onTap: () {},
              ),
            ],
          ),

          _buildSection(
            context,
            title: 'Acerca de',
            children: [
              _buildSettingTile(
                context,
                icon: Icons.info_outline,
                title: 'Versión',
                subtitle: '1.0.0',
                onTap: () {},
              ),
              _buildSettingTile(
                context,
                icon: Icons.policy_outlined,
                title: 'Términos y Condiciones',
                trailing: const Icon(Icons.open_in_new),
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.only(bottom: 24),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}
