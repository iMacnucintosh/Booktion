import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/author.dart';
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
  late final TextEditingController _serieController;
  late final TextEditingController _numPaginasController;
  late final TextEditingController _posicionController;
  late final TextEditingController _resumenController;
  late final TextEditingController _urlController;
  late final TextEditingController _etiquetasController;
  late final TextEditingController _generosController;
  late final TextEditingController _newAuthorController;

  late BookStatus _estado;
  int? _valoracion;
  bool _isLoading = false;
  Author? _selectedAuthor;

  bool get _isEditing => widget.book != null;

  @override
  void initState() {
    super.initState();
    final book = widget.book;

    _nombreController = TextEditingController(text: book?.nombre ?? '');
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
    _newAuthorController = TextEditingController();

    _estado = book?.estado ?? BookStatus.pendiente;
    _valoracion = book?.valoracion;
    _selectedAuthor =
        book?.autores.isNotEmpty == true ? book!.autores.first : null;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _serieController.dispose();
    _numPaginasController.dispose();
    _posicionController.dispose();
    _resumenController.dispose();
    _urlController.dispose();
    _etiquetasController.dispose();
    _generosController.dispose();
    _newAuthorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch suggestions providers
    final seriesSuggestions =
        ref.watch(seriesSuggestionsProvider).valueOrNull ?? [];
    final genreSuggestions =
        ref.watch(genreSuggestionsProvider).valueOrNull ?? [];
    final tagSuggestions = ref.watch(tagSuggestionsProvider).valueOrNull ?? [];
    final authorsAsync = ref.watch(authorsListProvider);

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
            // Author selector
            _buildAuthorSelector(authorsAsync),
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
      autores: _selectedAuthor != null ? [_selectedAuthor!] : [],
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
      success =
          await ref.read(updateBookNotifierProvider.notifier).update(book);
    } else {
      success =
          await ref.read(createBookNotifierProvider.notifier).create(book);
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

  Widget _buildAuthorSelector(AsyncValue<List<Author>> authorsAsync) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Autor',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: 8),
        authorsAsync.when(
          data: (authors) {
            return Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.colorScheme.outline),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Author?>(
                        isExpanded: true,
                        hint: const Text('Seleccionar autor...'),
                        value: _selectedAuthor != null
                            ? authors
                                    .where((a) => a.id == _selectedAuthor!.id)
                                    .firstOrNull ??
                                _selectedAuthor
                            : null,
                        items: [
                          // Option to clear selection
                          const DropdownMenuItem<Author?>(
                            value: null,
                            child: Text('Sin autor',
                                style: TextStyle(fontStyle: FontStyle.italic)),
                          ),
                          ...authors.map((author) {
                            return DropdownMenuItem<Author?>(
                              value: author,
                              child: Row(
                                children: [
                                  if (author.iconUrl != null)
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundImage:
                                          NetworkImage(author.iconUrl!),
                                    )
                                  else
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: AppColors.primary
                                          .withValues(alpha: 0.2),
                                      child: const Icon(Icons.person,
                                          size: 14, color: AppColors.primary),
                                    ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      author.nombre,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                        onChanged: (author) {
                          setState(() {
                            _selectedAuthor = author;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Button to create new author
                IconButton(
                  onPressed: () => _showCreateAuthorDialog(),
                  icon: const Icon(Icons.person_add_rounded),
                  tooltip: 'Crear nuevo autor',
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (e, _) => Text(
            'Error al cargar autores: $e',
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ),
      ],
    );
  }

  Future<void> _showCreateAuthorDialog() async {
    _newAuthorController.clear();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo autor'),
        content: TextField(
          controller: _newAuthorController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nombre del autor',
            hintText: 'Ej: Brandon Sanderson',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Crear'),
          ),
        ],
      ),
    );

    if (result == true && _newAuthorController.text.trim().isNotEmpty) {
      final nombre = _newAuthorController.text.trim();
      final author =
          await ref.read(createAuthorNotifierProvider.notifier).create(nombre);
      if (author != null && mounted) {
        setState(() {
          _selectedAuthor = author;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Autor "$nombre" creado')),
        );
      }
    }
  }
}
