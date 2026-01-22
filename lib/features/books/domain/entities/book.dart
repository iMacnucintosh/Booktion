import 'package:freezed_annotation/freezed_annotation.dart';

import 'author.dart';

part 'book.freezed.dart';

/// Book reading status
enum BookStatus {
  pendiente('Pendiente'),
  enCurso('En curso'),
  terminado('Terminado');

  final String displayName;
  const BookStatus(this.displayName);

  static BookStatus fromString(String value) {
    return BookStatus.values.firstWhere(
      (status) => status.displayName.toLowerCase() == value.toLowerCase(),
      orElse: () => BookStatus.pendiente,
    );
  }
}

/// Book entity - Core domain model
@freezed
class Book with _$Book {
  const Book._();

  const factory Book({
    required String id,
    required String nombre,
    @Default([]) List<Author> autores,  // Authors from relation
    String? serie,
    @Default(BookStatus.pendiente) BookStatus estado,
    int? valoracion,
    @Default([]) List<String> etiquetas,
    @Default([]) List<String> generos,
    int? numPaginas,
    int? posicion,
    String? resumen,
    String? fechaTerminado,
    String? url,
    String? iconEmoji,      // Emoji icon from Notion
    String? iconUrl,        // External/file icon URL from Notion
    String? coverUrl,       // Cover image URL from Notion
  }) = _Book;

  /// Returns the author names as a single string (for display)
  String get autor => autores.map((a) => a.nombre).join(', ');

  /// Returns true if the book has been completed
  bool get isCompleted => estado == BookStatus.terminado;

  /// Returns true if the book is currently being read
  bool get isReading => estado == BookStatus.enCurso;

  /// Returns true if the book is pending
  bool get isPending => estado == BookStatus.pendiente;

  /// Returns the rating as stars (e.g., "⭐⭐⭐⭐")
  String get ratingStars {
    if (valoracion == null || valoracion! <= 0) return '';
    return '⭐' * valoracion!;
  }

  /// Returns a display-friendly string for genres
  String get generosDisplay => generos.join(', ');

  /// Returns a display-friendly string for tags
  String get etiquetasDisplay => etiquetas.join(', ');

  /// Creates an empty book for forms
  factory Book.empty() => const Book(
        id: '',
        nombre: '',
      );
}
