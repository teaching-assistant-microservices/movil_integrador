// lib/features/auth/ui/screens/register_screen.dart
// VERSIÓN CORREGIDA - Implementa todas las validaciones de seguridad

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:integrador/core/router/routes.dart';
import 'package:integrador/core/utils/validators.dart'; // ⬅️ NUEVO IMPORT
import 'package:integrador/features/auth/ui/providers/auth_provider.dart';
import 'package:integrador/themes/app_theme.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // 🔒 CORRECCIÓN 1: Agregar GlobalKey para el formulario
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _selectedAcademicLevel;

  // 🔒 CORRECCIÓN 2: Usar lista constante de InputValidators
  final List<String> _academicLevels = InputValidators.ALLOWED_ACADEMIC_LEVELS;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // 🔒 CORRECCIÓN 3: Validar formulario antes de enviar
  Future<void> _handleRegister() async {
    // Validar formulario completo
    if (!_formKey.currentState!.validate()) {
      return; // No continuar si hay errores de validación
    }

    final authProvider = context.read<AuthProvider>();

    // 🔒 CORRECCIÓN 4: Normalizar datos antes de enviar
    final normalizedEmail = InputValidators.normalizeEmail(
      _emailController.text,
    );
    final normalizedName = InputValidators.normalizeName(_nameController.text);
    final password = _passwordController.text.trim();

    final success = await authProvider.register(
      email: normalizedEmail,
      name: normalizedName,
      password: password,
      academicLevel: _selectedAcademicLevel,
    );

    if (!mounted) return;

    if (success) {
      context.go(AppRoutes.homePath);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Error al registrar'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: const Text('Crear Cuenta'), elevation: 0),
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                // 🔒 CORRECCIÓN 5: Usar GlobalKey en el Form
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 🔒 CORRECCIÓN 6: Usar validador robusto de nombre
                    TextFormField(
                      controller: _nameController,
                      enabled: !authProvider.isLoading,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Nombre Completo',
                        hintText: 'Juan Pérez',
                        prefixIcon: Icon(Icons.person_outline),
                        helperText: 'Solo letras y espacios (2-100 caracteres)',
                      ),
                      // 🔒 NUEVO: Usar validador de clase InputValidators
                      validator: InputValidators.validateName,
                      // 🔒 CORRECCIÓN 7: Limitar longitud en UI
                      maxLength: InputValidators.MAX_NAME_LENGTH,
                      buildCounter:
                          (
                            context, {
                            required currentLength,
                            required isFocused,
                            maxLength,
                          }) {
                            // Mostrar contador solo cuando está cerca del límite
                            if (currentLength >
                                InputValidators.MAX_NAME_LENGTH - 20) {
                              return Text(
                                '$currentLength/$maxLength',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: currentLength >= maxLength!
                                      ? AppTheme.errorColor
                                      : AppTheme.textSecondaryColor,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                    ),

                    const SizedBox(height: 16),

                    // 🔒 CORRECCIÓN 8: Usar validador robusto de email
                    TextFormField(
                      controller: _emailController,
                      enabled: !authProvider.isLoading,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'correo@ejemplo.com',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: InputValidators.validateEmail,
                      autocorrect: false,
                      enableSuggestions: false,
                      maxLength: InputValidators.MAX_EMAIL_LENGTH,
                      buildCounter:
                          (
                            _, {
                            required currentLength,
                            required isFocused,
                            maxLength,
                          }) {
                            return const SizedBox.shrink(); // Ocultar contador
                          },
                    ),

                    const SizedBox(height: 16),

                    // 🔒 CORRECCIÓN 9: Usar validador robusto de password
                    TextFormField(
                      controller: _passwordController,
                      enabled: !authProvider.isLoading,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        hintText: 'Mínimo 8 caracteres',
                        helperText:
                            'Debe contener mayúsculas, minúsculas y números',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(
                              () => _obscurePassword = !_obscurePassword,
                            );
                          },
                        ),
                      ),
                      validator: InputValidators.validatePassword,
                      maxLength: InputValidators.MAX_PASSWORD_LENGTH,
                      buildCounter:
                          (
                            _, {
                            required currentLength,
                            required isFocused,
                            maxLength,
                          }) {
                            return const SizedBox.shrink();
                          },
                    ),

                    const SizedBox(height: 16),

                    // 🔒 CORRECCIÓN 10: Validar coincidencia de contraseñas
                    TextFormField(
                      controller: _confirmPasswordController,
                      enabled: !authProvider.isLoading,
                      obscureText: _obscureConfirmPassword,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Confirmar Contraseña',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(
                              () => _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                            );
                          },
                        ),
                      ),
                      // 🔒 NUEVO: Usar validador de coincidencia
                      validator: (value) =>
                          InputValidators.validatePasswordMatch(
                            value,
                            _passwordController.text,
                          ),
                      maxLength: InputValidators.MAX_PASSWORD_LENGTH,
                      buildCounter:
                          (
                            _, {
                            required currentLength,
                            required isFocused,
                            maxLength,
                          }) {
                            return const SizedBox.shrink();
                          },
                    ),

                    const SizedBox(height: 16),

                    // 🔒 CORRECCIÓN 11: Validar nivel académico
                    DropdownButtonFormField<String>(
                      initialValue: _selectedAcademicLevel,
                      decoration: const InputDecoration(
                        labelText: 'Nivel Académico (Opcional)',
                        prefixIcon: Icon(Icons.school_outlined),
                        helperText: 'Nos ayuda a personalizar tu experiencia',
                      ),
                      items: _academicLevels.map((level) {
                        return DropdownMenuItem(
                          value: level,
                          child: Text(level),
                        );
                      }).toList(),
                      onChanged: authProvider.isLoading
                          ? null
                          : (value) {
                              setState(() => _selectedAcademicLevel = value);
                            },
                      // 🔒 NUEVO: Validar contra whitelist
                      validator: InputValidators.validateAcademicLevel,
                    ),

                    const SizedBox(height: 32),

                    // Register Button
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: authProvider.isLoading
                            ? null
                            : _handleRegister,
                        child: authProvider.isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text('Crear Cuenta'),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¿Ya tienes cuenta? ',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: authProvider.isLoading
                              ? null
                              : () => context.go(AppRoutes.loginPath),
                          child: const Text('Inicia Sesión'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
