// ========================================
// PANTALLA 4: GenerateMaterialScreen
// lib/features/reports/ui/screens/generate_report_screen.dart
// ========================================
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:integrador/common/widgets/detail_scaffold.dart';
import 'package:integrador/core/utils/validators.dart';
import 'package:integrador/themes/app_theme.dart';

class GenerateReportScreen extends StatefulWidget {
  const GenerateReportScreen({super.key});

  @override
  State<GenerateReportScreen> createState() => _GenerateReportScreenState();
}

class _GenerateReportScreenState extends State<GenerateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _topicController = TextEditingController();

  String _materialType = 'study-guide';
  String _level = 'Universidad';
  int _durationHours = 2;

  bool _isGenerating = false;

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _generateMaterial() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isGenerating = true);

    try {
      // TODO: Llamar al endpoint de generación
      // POST /api/v1/generation/study-guide o /lesson-plan

      await Future.delayed(const Duration(seconds: 2)); // Simulación

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Material generado exitosamente'),
            backgroundColor: AppTheme.successColor,
          ),
        );

        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DetailScaffold(
      title: 'Generar Material',
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Tipo de material
            Text(
              'Tipo de Material',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 12),

            _buildRadioOption(
              value: 'study-guide',
              groupValue: _materialType,
              title: '📝 Guía de Estudio',
              subtitle: 'Material para estudio individual',
              onChanged: (value) => setState(() => _materialType = value!),
            ),

            _buildRadioOption(
              value: 'lesson-plan',
              groupValue: _materialType,
              title: '📚 Plan de Clase',
              subtitle: 'Estructura para impartir clase',
              onChanged: (value) => setState(() => _materialType = value!),
            ),

            const SizedBox(height: 24),

            // Tema
            TextFormField(
              controller: _topicController,
              decoration: const InputDecoration(
                labelText: 'Tema o Tópico',
                hintText: 'Ej: Multiplicación de fracciones',
                prefixIcon: Icon(Icons.topic_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El tema es requerido';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Nivel
            DropdownButtonFormField<String>(
              initialValue: _level,
              decoration: const InputDecoration(
                labelText: 'Nivel Educativo',
                prefixIcon: Icon(Icons.school_outlined),
              ),
              items: InputValidators.ALLOWED_ACADEMIC_LEVELS.map((level) {
                return DropdownMenuItem(value: level, child: Text(level));
              }).toList(),
              onChanged: (value) => setState(() => _level = value!),
            ),

            const SizedBox(height: 16),

            // Duración (solo para plan de clase)
            if (_materialType == 'lesson-plan')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Duración: $_durationHours ${_durationHours == 1 ? "hora" : "horas"}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Slider(
                    value: _durationHours.toDouble(),
                    min: 1,
                    max: 8,
                    divisions: 7,
                    label: '$_durationHours h',
                    onChanged: (value) {
                      setState(() => _durationHours = value.toInt());
                    },
                  ),
                ],
              ),

            const SizedBox(height: 32),

            // Botón generar
            ElevatedButton.icon(
              onPressed: _isGenerating ? null : _generateMaterial,
              icon: _isGenerating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(_isGenerating ? 'Generando...' : 'Generar Material'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOption({
    required String value,
    required String groupValue,
    required String title,
    required String subtitle,
    required ValueChanged<String?> onChanged,
  }) {
    return Card(
      child: RadioListTile<String>(
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
      ),
    );
  }
}
