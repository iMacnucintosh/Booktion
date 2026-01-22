import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/book.dart';
import '../providers/books_provider.dart';
import '../widgets/autocomplete_field.dart';
import '../widgets/rating_stars.dart';

/// Page for creating or editing a book
class BookFormPage extends ConsumerStatefulWidget {
  final Book? book;

  const BookFormPage({super.key, this.book});

  @override
  ConsumerState<BookFormPage> createState() => _BookFormPageState();
}

class _BookFormPageState extends ConsumerState<BookFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreController;
  late final TextEditingController _autorController;
  late final TextEditingController _serieController;
  late final TextEditingController _numPaginasController;
  late final TextEditingController _posicionController;
  late final TextEditingController _resumenController;
  late final TextEditingController _urlController;
  late final TextEditingController _etiquetasController;
  late final TextEditingController _generosController;

  late BookStatus _estado;
  int? _valoracion;
  bool _isLoading = false;

  bool get _isEditing => widget.book != null;

  @override
  void initState() {
    super.initState();
    final book = widget.book;

    _nombreController = TextEditingController(text: book?.nombre ?? '');
    _autorController = TextEditingController(text: book?.autor ?? '');
    _serieController = TextEditingController(text: book?.serie ?? '');
    _numPaginasController = TextEditingController(
      text: book?.numPaginas?.toString() ?? '',
    );
    _posicionController = TextEditingController(
      text: book?.posicion?.toString() ?? '',
    );
    _resumenController = TextEditingController(text: book?.resumen ?? '');
    _urlController = TextEditingController(text: book?.url ?? '');
    _etiquetasController = TextEditingController(
      text: book?.etiquetas.join(', ') ?? '',
    );
    _generosController = TextEditingController(
      text: book?.generos.join(', ') ?? '',
    );

    _estado = book?.estado ?? BookStatus.pendiente;
    _valoracion = book?.valoracion;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _autorController.dispose();
    _serieController.dispose();
    _numPaginasController.dispose();
    _posicionController.dispose();
    _resumenController.dispose();
    _urlController.dispose();
    _etiquetasController.dispose();
    _generosController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch suggestions providers
    final authorSuggestions = ref.watch(authorSuggestionsProvider).valueOrNull ?? [];
    final seriesSuggestions = ref.watch(seriesSuggestionsProvider).valueOrNull ?? [];
    final genreSuggestions = ref.watch(genreSuggestionsProvider).valueOrNull ?? [];
    final tagSuggestions = ref.watch(tagSuggestionsProvider).valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar libro' : 'Nuevo libro'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close_rounded),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveBook,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Guardar'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Required fields section
            _buildSectionTitle('Información básica *'),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _nombreController,
              label: 'Título del libro',
              validator: (value) =>
                  value?.isEmpty == true ? 'El título es requerido' : null,
            ),
            const SizedBox(height: 16),
            // Author (read-only info, managed in Notion via relations)
            AutocompleteField(
              controller: _autorController,
              label: 'Autor (gestionar en Notion)',
              suggestions: authorSuggestions,
              // Author is optional - managed via Notion relations
            ),
            const SizedBox(height: 16),
            // Series with autocomplete
            AutocompleteField(
              controller: _serieController,
              label: 'Serie (opcional)',
              suggestions: seriesSuggestions,
            ),

            const SizedBox(height: 32),

            // Status section
            _buildSectionTitle('Estado de lectura'),
            const SizedBox(height: 12),
            _buildStatusSelector(),

            const SizedBox(height: 32),

            // Rating section
            _buildSectionTitle('Valoración'),
            const SizedBox(height: 12),
            _buildRatingSelector(),

            const SizedBox(height: 32),

            // Details section
            _buildSectionTitle('Detalles'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _numPaginasController,
                    label: 'Nº Páginas',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _posicionController,
                    label: 'Posición',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Tags section
            _buildSectionTitle('Etiquetas y géneros'),
            const SizedBox(height: 12),
            // Tags with chip input
            ChipInputField(
              controller: _etiquetasController,
              label: 'Etiquetas',
              suggestions: tagSuggestions,
              hint: 'Añadir etiqueta...',
            ),
            const SizedBox(height: 16),
            // Genres with chip input
            ChipInputField(
              controller: _generosController,
              label: 'Géneros',
              suggestions: genreSuggestions,
              hint: 'Añadir género...',
            ),

            const SizedBox(height: 32),

            // Additional info section
            _buildSectionTitle('Información adicional'),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _urlController,
              label: 'URL (enlace a video, reseña, etc.)',
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _resumenController,
              label: 'Resumen / Notas',
              maxLines: 5,
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        alignLabelWithHint: maxLines > 1,
      ),
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
    );
  }

  Widget _buildStatusSelector() {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: BookStatus.values.map((status) {
        final isSelected = _estado == status;
        return GestureDetector(
          onTap: () => setState(() => _estado = status),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? _getStatusColor(status)
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? _getStatusColor(status)
                    : theme.colorScheme.outline,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getStatusIcon(status),
                  size: 18,
                  color: isSelected
                      ? Colors.white
                      : theme.textTheme.bodyMedium?.color,
                ),
                const SizedBox(width: 8),
                Text(
                  status.displayName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : theme.textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRatingSelector() {
    return Row(
      children: [
        RatingStars(
          rating: _valoracion,
          size: 32,
          interactive: true,
          onRatingChanged: (rating) {
            setState(() {
              // Toggle off if same rating is tapped
              _valoracion = _valoracion == rating ? null : rating;
            });
          },
        ),
        if (_valoracion != null) ...[
          const SizedBox(width: 16),
          TextButton(
            onPressed: () => setState(() => _valoracion = null),
            child: const Text('Limpiar'),
          ),
        ],
      ],
    );
  }

  Color _getStatusColor(BookStatus status) {
    switch (status) {
      case BookStatus.pendiente:
        return AppColors.statusPending;
      case BookStatus.enCurso:
        return AppColors.statusReading;
      case BookStatus.terminado:
        return AppColors.statusCompleted;
    }
  }

  IconData _getStatusIcon(BookStatus status) {
    switch (status) {
      case BookStatus.pendiente:
        return Icons.schedule_rounded;
      case BookStatus.enCurso:
        return Icons.auto_stories_rounded;
      case BookStatus.terminado:
        return Icons.check_circle_rounded;
    }
  }

  List<String> _parseCommaSeparated(String text) {
    if (text.trim().isEmpty) return [];
    return text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<void> _saveBook() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final book = Book(
      id: widget.book?.id ?? '',
      nombre: _nombreController.text.trim(),
      // Keep existing authors if editing, otherwise empty (authors are relations in Notion)
      autores: widget.book?.autores ?? [],
      serie: _serieController.text.trim().isEmpty
          ? null
          : _serieController.text.trim(),
      estado: _estado,
      valoracion: _valoracion,
      etiquetas: _parseCommaSeparated(_etiquetasController.text),
      generos: _parseCommaSeparated(_generosController.text),
      numPaginas: int.tryParse(_numPaginasController.text),
      posicion: int.tryParse(_posicionController.text),
      resumen: _resumenController.text.trim().isEmpty
          ? null
          : _resumenController.text.trim(),
      url: _urlController.text.trim().isEmpty
          ? null
          : _urlController.text.trim(),
      fechaTerminado: widget.book?.fechaTerminado,
    );

    bool success;
    if (_isEditing) {
      success = await ref.read(updateBookNotifierProvider.notifier).update(book);
    } else {
      success = await ref.read(createBookNotifierProvider.notifier).create(book);
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing ? 'Libro actualizado' : 'Libro creado',
          ),
        ),
      );
    } else if (mounted) {
      final error = _isEditing
          ? ref.read(updateBookNotifierProvider).error
          : ref.read(createBookNotifierProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Error al guardar el libro'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
