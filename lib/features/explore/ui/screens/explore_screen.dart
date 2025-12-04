// lib/features/explore/ui/screens/explore_screen.dart
// VERSIÓN CORREGIDA - Implementa validación y sanitización de búsqueda

import 'package:flutter/material.dart';
import 'package:integrador/common/widgets/widgets.dart';
import 'package:integrador/core/mocks/documents_mock_data.dart';
import 'package:integrador/core/utils/validators.dart'; // ⬅️ NUEVO IMPORT
import 'package:integrador/themes/app_theme.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _selectedCategory = 'Todos';
  final List<String> _categories = [
    'Todos',
    'Matemáticas',
    'Pedagogía',
    'Metodología',
    'Ciencias',
  ];

  // 🔒 CORRECCIÓN 1: Agregar controller y estado de búsqueda
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 🔒 CORRECCIÓN 2: Sanitizar y validar búsqueda
  void _onSearchChanged() {
    setState(() {
      // Sanitizar la búsqueda
      _searchQuery = InputValidators.sanitizeSearchQuery(
        _searchController.text,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final allDocuments = DocumentsMockData.mockDocuments;

    // Filtrar por categoría
    var filteredDocs = _selectedCategory == 'Todos'
        ? allDocuments
        : allDocuments
              .where((d) => d['primaryCategory'] == _selectedCategory)
              .toList();

    // 🔒 CORRECCIÓN 3: Filtrar por búsqueda sanitizada
    if (_searchQuery.isNotEmpty) {
      filteredDocs = filteredDocs.where((doc) {
        final title = (doc['title'] as String).toLowerCase();
        final keywords = (doc['keywords'] as List).join(' ').toLowerCase();
        final searchLower = _searchQuery.toLowerCase();

        return title.contains(searchLower) || keywords.contains(searchLower);
      }).toList();
    }

    return MainScaffold(
      title: 'Explorar',
      currentNavIndex: 2,
      body: Column(
        children: [
          // 🔒 CORRECCIÓN 4: Search Bar con validación
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              // 🔒 Limitar longitud máxima
              maxLength: InputValidators.MAX_SEARCH_LENGTH,
              buildCounter:
                  (
                    context, {
                    required currentLength,
                    required isFocused,
                    maxLength,
                  }) {
                    // Mostrar contador solo cerca del límite
                    if (currentLength >
                        InputValidators.MAX_SEARCH_LENGTH - 20) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '$currentLength / $maxLength',
                          style: TextStyle(
                            fontSize: 11,
                            color: currentLength >= maxLength!
                                ? AppTheme.errorColor
                                : AppTheme.textSecondaryColor,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
              decoration: InputDecoration(
                hintText: 'Buscar documentos...',
                prefixIcon: const Icon(Icons.search),
                // 🔒 Botón para limpiar búsqueda
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Category Filters
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : AppTheme.textSecondaryColor,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // 🔒 CORRECCIÓN 5: Mostrar indicador de búsqueda activa
          if (_searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    size: 16,
                    color: AppTheme.textSecondaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Buscando: "$_searchQuery"',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${filteredDocs.length} resultados',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          // Documents Grid
          Expanded(
            child: filteredDocs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppTheme.textLightColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No se encontraron documentos'
                              : 'No hay documentos en esta categoría',
                          style: TextStyle(color: AppTheme.textSecondaryColor),
                        ),
                        if (_searchQuery.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                            icon: const Icon(Icons.clear),
                            label: const Text('Limpiar búsqueda'),
                          ),
                        ],
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final doc = filteredDocs[index];
                      return _DocumentCard(doc: doc);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final Map<String, dynamic> doc;

  const _DocumentCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // TODO: Navegar a detalle
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Document Icon/Preview
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.getCategoryColor(
                  doc['primaryCategory'],
                ).withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.description,
                  size: 48,
                  color: AppTheme.getCategoryColor(doc['primaryCategory']),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    doc['title'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Category Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.getCategoryColor(
                        doc['primaryCategory'],
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      doc['primaryCategory'],
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.getCategoryColor(
                          doc['primaryCategory'],
                        ),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Metadata
                  Row(
                    children: [
                      Icon(
                        Icons.insert_drive_file,
                        size: 12,
                        color: AppTheme.textSecondaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${doc['fileSize']} MB',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      if (doc['pageCount'] != null) ...[
                        const SizedBox(width: 12),
                        Icon(
                          Icons.article,
                          size: 12,
                          color: AppTheme.textSecondaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${doc['pageCount']} págs',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
