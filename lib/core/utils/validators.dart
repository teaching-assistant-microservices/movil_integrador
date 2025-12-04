// lib/core/utils/validators.dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mime/mime.dart';

/// Sistema completo de validación para entradas del usuario
/// Implementa todas las correcciones de seguridad del análisis
class InputValidators {
  // ============================================
  // CONSTANTES DE VALIDACIÓN
  // ============================================
  
  /// RFC 5321 - Longitud máxima de email
  static const int MAX_EMAIL_LENGTH = 254;
  
  /// Longitud máxima recomendada para contraseñas (NIST SP 800-63B)
  static const int MAX_PASSWORD_LENGTH = 128;
  static const int MIN_PASSWORD_LENGTH = 8;
  
  /// Longitud máxima para nombres de usuario
  static const int MAX_NAME_LENGTH = 100;
  static const int MIN_NAME_LENGTH = 2;
  
  /// Longitud máxima para mensajes de chat (prevención de DoS)
  static const int MAX_MESSAGE_LENGTH = 2000;
  
  /// Longitud máxima para búsquedas
  static const int MAX_SEARCH_LENGTH = 200;
  
  /// Tamaño máximo de archivo (50MB en bytes)
  static const int MAX_FILE_SIZE = 50 * 1024 * 1024;
  
  /// Expresión regular RFC 5322 para emails
  static final RegExp _emailRegex = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
  );
  
  /// Expresión regular para nombres (solo letras, espacios y acentos)
  static final RegExp _nameRegex = RegExp(
    r'^[a-zA-ZáéíóúñÑÁÉÍÓÚüÜ\s]+$'
  );
  
  /// Lista de niveles académicos permitidos
  static const List<String> ALLOWED_ACADEMIC_LEVELS = [
    'Primaria',
    'Secundaria',
    'Preparatoria',
    'Universidad',
  ];
  
  // ============================================
  // VALIDADORES DE FORMULARIOS
  // ============================================
  
  /// Valida y sanitiza email según RFC 5322
  /// 
  /// Errores retornados:
  /// - 'Email requerido' si está vacío
  /// - 'Email demasiado largo (máx N caracteres)' si excede límite
  /// - 'Formato de email inválido' si no cumple RFC 5322
  static String? validateEmail(String? value) {
    final v = (value ?? '').trim();
    
    if (v.isEmpty) {
      return 'Email requerido';
    }
    
    if (v.length > MAX_EMAIL_LENGTH) {
      return 'Email demasiado largo (máx $MAX_EMAIL_LENGTH caracteres)';
    }
    
    if (!_emailRegex.hasMatch(v)) {
      return 'Formato de email inválido';
    }
    
    return null;
  }
  
  /// Valida password con requisitos de complejidad
  /// 
  /// Requisitos:
  /// - Mínimo 8 caracteres
  /// - Máximo 128 caracteres
  /// - Al menos una mayúscula
  /// - Al menos una minúscula
  /// - Al menos un número
  static String? validatePassword(String? value) {
    final v = value ?? '';
    
    if (v.isEmpty) {
      return 'Contraseña requerida';
    }
    
    if (v.length < MIN_PASSWORD_LENGTH) {
      return 'Mínimo $MIN_PASSWORD_LENGTH caracteres';
    }
    
    if (v.length > MAX_PASSWORD_LENGTH) {
      return 'Máximo $MAX_PASSWORD_LENGTH caracteres';
    }
    
    // Verificar complejidad básica
    final hasUppercase = v.contains(RegExp(r'[A-Z]'));
    final hasLowercase = v.contains(RegExp(r'[a-z]'));
    final hasDigit = v.contains(RegExp(r'[0-9]'));
    
    if (!hasUppercase || !hasLowercase || !hasDigit) {
      return 'Debe contener mayúsculas, minúsculas y números';
    }
    
    return null;
  }
  
  /// Valida que dos contraseñas coincidan
  static String? validatePasswordMatch(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Por favor confirma tu contraseña';
    }
    
    if (value != originalPassword) {
      return 'Las contraseñas no coinciden';
    }
    
    return null;
  }
  
  /// Valida nombre completo
  /// 
  /// Requisitos:
  /// - Mínimo 2 caracteres
  /// - Máximo 100 caracteres
  /// - Solo letras, espacios y acentos españoles
  static String? validateName(String? value) {
    final v = (value ?? '').trim();
    
    if (v.isEmpty) {
      return 'Nombre requerido';
    }
    
    if (v.length < MIN_NAME_LENGTH) {
      return 'Mínimo $MIN_NAME_LENGTH caracteres';
    }
    
    if (v.length > MAX_NAME_LENGTH) {
      return 'Máximo $MAX_NAME_LENGTH caracteres';
    }
    
    if (!_nameRegex.hasMatch(v)) {
      return 'Solo letras y espacios permitidos';
    }
    
    return null;
  }
  
  /// Valida campo no vacío genérico
  static String? validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es requerido';
    }
    return null;
  }
  
  /// Valida que el nivel académico esté en la lista permitida
  static String? validateAcademicLevel(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Campo opcional
    }
    
    if (!ALLOWED_ACADEMIC_LEVELS.contains(value)) {
      return 'Nivel académico no válido';
    }
    
    return null;
  }
  
  // ============================================
  // SANITIZACIÓN DE MENSAJES (CRÍTICO)
  // ============================================
  
  /// Sanitiza mensaje para chat - CRÍTICO para prevención de Prompt Injection
  /// 
  /// Protecciones implementadas:
  /// 1. Limita longitud a MAX_MESSAGE_LENGTH
  /// 2. Remueve caracteres de control peligrosos
  /// 3. Limita newlines consecutivos
  /// 4. Detecta patrones sospechosos
  static String sanitizeChatMessage(String message) {
    var sanitized = message.trim();
    
    // 1. Limitar longitud
    if (sanitized.length > MAX_MESSAGE_LENGTH) {
      sanitized = sanitized.substring(0, MAX_MESSAGE_LENGTH);
    }
    
    // 2. Remover caracteres de control peligrosos
    // Mantiene: tab (\t), newline (\n), carriage return (\r)
    // Elimina: NULL, bell, backspace, etc.
    sanitized = sanitized.replaceAll(
      RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), 
      ''
    );
    
    // 3. Limitar newlines consecutivos (máx 3)
    sanitized = sanitized.replaceAll(
      RegExp(r'\n{4,}'), 
      '\n\n\n'
    );
    
    // 4. Detectar patrones sospechosos (logging, no bloqueo)
    final dangerousPatterns = [
      'ignore previous',
      'ignore all previous',
      'system:',
      '<system>',
      'you are now',
      'new instructions',
      'disregard',
    ];
    
    for (final pattern in dangerousPatterns) {
      if (sanitized.toLowerCase().contains(pattern)) {
        debugPrint('⚠️ Mensaje con patrón sospechoso detectado: $pattern');
        // NO bloqueamos para evitar falsos positivos
        // Solo logging para monitoreo
      }
    }
    
    return sanitized;
  }
  
  /// Valida longitud de mensaje de chat
  static String? validateChatMessage(String? value) {
    final v = (value ?? '').trim();
    
    if (v.isEmpty) {
      return 'El mensaje no puede estar vacío';
    }
    
    if (v.length > MAX_MESSAGE_LENGTH) {
      return 'Mensaje demasiado largo (máx $MAX_MESSAGE_LENGTH caracteres)';
    }
    
    return null;
  }
  
  /// Sanitiza query de búsqueda
  static String sanitizeSearchQuery(String query) {
    var sanitized = query.trim();
    
    // Limitar longitud
    if (sanitized.length > MAX_SEARCH_LENGTH) {
      sanitized = sanitized.substring(0, MAX_SEARCH_LENGTH);
    }
    
    // Remover caracteres especiales peligrosos para SQL/NoSQL
    sanitized = sanitized.replaceAll(RegExp(r'''[<>"'/;]'''), '');
    
    return sanitized;
  }
  
  /// Valida query de búsqueda
  static String? validateSearchQuery(String? value) {
    final v = (value ?? '').trim();
    
    if (v.isEmpty) {
      return null; // Búsqueda vacía es válida
    }
    
    if (v.length > MAX_SEARCH_LENGTH) {
      return 'Búsqueda demasiado larga (máx $MAX_SEARCH_LENGTH caracteres)';
    }
    
    return null;
  }
  
  // ============================================
  // VALIDACIÓN DE ARCHIVOS (CRÍTICO)
  // ============================================
  
  /// Valida archivo PDF - CRÍTICO para seguridad
  /// 
  /// Validaciones implementadas:
  /// 1. Extensión .pdf
  /// 2. Tamaño máximo 50MB
  /// 3. Nombre de archivo sanitizado (sin path traversal)
  /// 4. MIME type real (si hay bytes disponibles)
  static Future<String?> validatePdfFile(PlatformFile file) async {
    // 1. Validar extensión
    if (!file.name.toLowerCase().endsWith('.pdf')) {
      return 'Solo archivos PDF permitidos';
    }
    
    // 2. Validar tamaño
    if (file.size > MAX_FILE_SIZE) {
      final sizeMB = (MAX_FILE_SIZE / (1024 * 1024)).toStringAsFixed(0);
      return 'Archivo excede ${sizeMB}MB';
    }
    
    if (file.size == 0) {
      return 'Archivo vacío no permitido';
    }
    
    // 3. Sanitizar y validar nombre
    final sanitizedName = sanitizeFilename(file.name);
    if (sanitizedName != file.name) {
      return 'Nombre de archivo contiene caracteres no permitidos';
    }
    
    if (sanitizedName.contains('..')) {
      return 'Nombre de archivo inválido (path traversal detectado)';
    }
    
    // 4. Validar MIME real (solo si hay bytes disponibles)
    if (file.bytes != null && file.bytes!.isNotEmpty) {
      final mime = lookupMimeType(file.name, headerBytes: file.bytes);
      if (mime != 'application/pdf') {
        return 'Archivo no es un PDF válido (MIME: ${mime ?? "desconocido"})';
      }
    }
    
    return null; // Válido
  }
  
  /// Sanitiza nombre de archivo
  /// 
  /// - Remueve caracteres especiales peligrosos
  /// - Previene path traversal
  /// - Mantiene solo: letras, números, guiones, puntos, espacios
  static String sanitizeFilename(String filename) {
    // Remover espacios al inicio/final
    var sanitized = filename.trim();
    
    // Permitir solo caracteres seguros: letras, números, espacios, guiones, puntos, guiones bajos
    sanitized = sanitized.replaceAll(
      RegExp(r'[^\w\s.-]'), 
      '_'
    );
    
    // Prevenir múltiples puntos consecutivos (anti path traversal)
    sanitized = sanitized.replaceAll(RegExp(r'\.{2,}'), '.');
    
    // Limitar longitud del nombre
    if (sanitized.length > 255) {
      // Mantener extensión
      final extension = sanitized.split('.').last;
      sanitized = '${sanitized.substring(0, 250 - extension.length)}.$extension';
    }
    
    return sanitized;
  }
  
  // ============================================
  // NORMALIZACIÓN DE DATOS
  // ============================================
  
  /// Normaliza email (trim + lowercase)
  static String normalizeEmail(String email) {
    return email.trim().toLowerCase();
  }
  
  /// Normaliza nombre (trim + capitalizar primera letra de cada palabra)
  static String normalizeName(String name) {
    final trimmed = name.trim();
    return trimmed.split(' ')
      .where((word) => word.isNotEmpty)
      .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
      .join(' ');
  }
  
  /// Normaliza cualquier texto (trim + remover múltiples espacios)
  static String normalizeText(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }
}

/// Extension methods para facilitar uso de validadores
extension StringValidationExtensions on String? {
  /// Valida email
  String? get emailError => InputValidators.validateEmail(this);
  
  /// Valida password
  String? get passwordError => InputValidators.validatePassword(this);
  
  /// Valida nombre
  String? get nameError => InputValidators.validateName(this);
  
  /// Normaliza email
  String normalizeAsEmail() => InputValidators.normalizeEmail(this ?? '');
  
  /// Normaliza nombre
  String normalizeAsName() => InputValidators.normalizeName(this ?? '');
}

/// Validador compuesto para formularios complejos
class FormValidatorBuilder {
  final List<String? Function()> _validators = [];
  
  /// Agrega un validador al builder
  FormValidatorBuilder add(String? Function() validator) {
    _validators.add(validator);
    return this;
  }
  
  /// Ejecuta todos los validadores y retorna el primer error encontrado
  String? validate() {
    for (final validator in _validators) {
      final error = validator();
      if (error != null) {
        return error;
      }
    }
    return null;
  }
}