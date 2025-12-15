// lib/common/widgets/detail_scaffold.dart

import 'package:flutter/material.dart';
import 'package:integrador/themes/app_theme.dart';

/// Scaffold para pantallas de detalle con navegación hacia atrás
class DetailScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final FloatingActionButton? floatingActionButton;
  final PreferredSizeWidget? bottom;
  final Color? backgroundColor;

  const DetailScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.bottom,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: AppTheme.textPrimaryColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimaryColor,
        elevation: 0,
        // 🔥 ESTO ES CLAVE: Flutter automáticamente agrega el botón back
        // si detecta que hay rutas en el stack
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
                tooltip: 'Volver',
              )
            : null,
        actions: actions,
        bottom: bottom,
        iconTheme: const IconThemeData(color: AppTheme.textPrimaryColor),
      ),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
