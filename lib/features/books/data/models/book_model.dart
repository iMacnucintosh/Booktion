import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/book.dart';
import 'author_model.dart';

part 'book_model.freezed.dart';
part 'book_model.g.dart';

/// Data model for Book - handles Notion API JSON conversion
@freezed
class BookModel with _$BookModel {
  const BookModel._();

  const factory BookModel({
    required String id,
    required String nombre,
    @Default([]) List<String> autorIds,      // Author relation IDs from Notion
    @Default([]) List<AuthorModel> autores,  // Resolved author data
    String? serie,
    @Default('Pendiente') String estado,
    int? valoracion,
    @Default([]) List<String> etiquetas,
    @Default([]) List<String> generos,
    int? numPaginas,
    int? posicion,
    String? resumen,
    String? fechaTerminado,
    String? url,
    String? iconEmoji,
    String? iconUrl,
    String? coverUrl,
  }) = _BookModel;

  /// Creates BookModel from Notion API response
  factory BookModel.fromNotionJson(Map<String, dynamic> json) {
    final properties = json['properties'] as Map<String, dynamic>;
    
    final estadoValue = _extractSelect(properties['Estado']);
    final icon = _extractIcon(json['icon']);
    final cover = _extractCover(json['cover']);
    
    return BookModel(
      id: json['id'] as String,
      nombre: _extractTitle(properties['Nombre']),
      autorIds: _extractRelationIds(properties['Autor']),
      serie: _extractMultiSelectAsString(properties['Serie']),
      estado: estadoValue ?? 'Pendiente',
      valoracion: _extractRating(properties['Valoración']),
      etiquetas: _extractMultiSelect(properties['Etiquetas']),
      generos: _extractMultiSelect(properties['Género']),
      numPaginas: _extractNumber(properties['Nº Páginas']),
      posicion: _extractNumber(properties['Posición']),
      resumen: _extractRichText(properties['Resumen']),
      fechaTerminado: _extractDateRange(properties['Terminado']),
      url: _extractUrl(properties['URL']),
      iconEmoji: icon['emoji'],
      iconUrl: icon['url'],
      coverUrl: cover,
    );
  }

  /// Returns a copy with resolved author data
  BookModel withAuthors(List<AuthorModel> resolvedAuthors) {
    return copyWith(autores: resolvedAuthors);
  }

  /// Converts BookModel to Notion API properties format for creating/updating
  Map<String, dynamic> toNotionProperties() {
    final properties = <String, dynamic>{
      'Nombre': {
        'title': [
          {
            'text': {'content': nombre}
          }
        ]
      },
      'Estado': {
        'status': {'name': estado}
      },
    };

    // Autor is a relation - use author IDs
    if (autorIds.isNotEmpty) {
      properties['Autor'] = {
        'relation': autorIds.map((id) => {'id': id}).toList()
      };
    }

    // Serie is multi_select - split by comma if multiple series
    if (serie != null && serie!.isNotEmpty) {
      final series = serie!.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty);
      properties['Serie'] = {
        'multi_select': series.map((s) => {'name': s}).toList()
      };
    }

    if (valoracion != null && valoracion! > 0) {
      properties['Valoración'] = {
        'select': {'name': _ratingToStars(valoracion!)}
      };
    }

    if (etiquetas.isNotEmpty) {
      properties['Etiquetas'] = {
        'multi_select': etiquetas.map((e) => {'name': e}).toList()
      };
    }

    if (generos.isNotEmpty) {
      properties['Género'] = {
        'multi_select': generos.map((g) => {'name': g}).toList()
      };
    }

    // Nº Páginas is rich_text (not number)
    if (numPaginas != null) {
      properties['Nº Páginas'] = {
        'rich_text': [
          {
            'text': {'content': numPaginas.toString()}
          }
        ]
      };
    }

    // Posición - check if it's number or rich_text in your DB
    if (posicion != null) {
      properties['Posición'] = {'number': posicion};
    }

    if (resumen != null && resumen!.isNotEmpty) {
      properties['Resumen'] = {
        'rich_text': [
          {
            'text': {'content': resumen}
          }
        ]
      };
    }

    if (url != null && url!.isNotEmpty) {
      properties['URL'] = {'url': url};
    }

    return properties;
  }

  /// Converts to domain entity
  Book toEntity() {
    return Book(
      id: id,
      nombre: nombre,
      autores: autores.map((a) => a.toEntity()).toList(),
      serie: serie,
      estado: BookStatus.fromString(estado),
      valoracion: valoracion,
      etiquetas: etiquetas,
      generos: generos,
      numPaginas: numPaginas,
      posicion: posicion,
      resumen: resumen,
      fechaTerminado: fechaTerminado,
      url: url,
      iconEmoji: iconEmoji,
      iconUrl: iconUrl,
      coverUrl: coverUrl,
    );
  }

  /// Creates BookModel from domain entity
  factory BookModel.fromEntity(Book book) {
    return BookModel(
      id: book.id,
      nombre: book.nombre,
      autorIds: book.autores.map((a) => a.id).toList(),
      autores: book.autores.map((a) => AuthorModel.fromEntity(a)).toList(),
      serie: book.serie,
      estado: book.estado.displayName,
      valoracion: book.valoracion,
      etiquetas: book.etiquetas,
      generos: book.generos,
      numPaginas: book.numPaginas,
      posicion: book.posicion,
      resumen: book.resumen,
      fechaTerminado: book.fechaTerminado,
      url: book.url,
      iconEmoji: book.iconEmoji,
      iconUrl: book.iconUrl,
      coverUrl: book.coverUrl,
    );
  }

  factory BookModel.fromJson(Map<String, dynamic> json) =>
      _$BookModelFromJson(json);
}

// Helper functions for Notion JSON extraction
String _extractTitle(dynamic property) {
  if (property == null) return '';
  final titleList = property['title'] as List?;
  if (titleList == null || titleList.isEmpty) return '';
  return (titleList[0]['plain_text'] as String?) ?? '';
}

String? _extractRichText(dynamic property) {
  if (property == null) return null;
  final richTextList = property['rich_text'] as List?;
  if (richTextList == null || richTextList.isEmpty) return null;
  
  // Concatenate all text blocks
  final buffer = StringBuffer();
  for (final block in richTextList) {
    buffer.write(block['plain_text'] as String? ?? '');
  }
  final result = buffer.toString();
  return result.isEmpty ? null : result;
}

/// Extract relation IDs from a relation property
List<String> _extractRelationIds(dynamic property) {
  if (property == null) return [];
  
  final type = property['type'] as String?;
  
  if (type == 'relation') {
    final relations = property['relation'] as List?;
    if (relations == null || relations.isEmpty) return [];
    
    return relations
        .map((r) => r['id'] as String?)
        .whereType<String>()
        .toList();
  }
  
  return [];
}

String? _extractSelect(dynamic property) {
  if (property == null) return null;
  
  // Handle both 'select' and 'status' types from Notion
  final type = property['type'] as String?;
  
  if (type == 'status') {
    final status = property['status'] as Map<String, dynamic>?;
    if (status == null) return null;
    return status['name'] as String?;
  }
  
  if (type == 'select') {
    final select = property['select'] as Map<String, dynamic>?;
    if (select == null) return null;
    return select['name'] as String?;
  }
  
  return null;
}

List<String> _extractMultiSelect(dynamic property) {
  if (property == null) return [];
  final multiSelect = property['multi_select'] as List?;
  if (multiSelect == null || multiSelect.isEmpty) return [];
  return multiSelect.map((e) => e['name'] as String).toList();
}

/// Extract multi_select as a comma-separated string
String? _extractMultiSelectAsString(dynamic property) {
  if (property == null) return null;
  final multiSelect = property['multi_select'] as List?;
  if (multiSelect == null || multiSelect.isEmpty) return null;
  
  final names = multiSelect
      .map((e) => e['name'] as String?)
      .whereType<String>()
      .toList();
  
  return names.isNotEmpty ? names.join(', ') : null;
}

int? _extractNumber(dynamic property) {
  if (property == null) return null;
  
  final type = property['type'] as String?;
  
  // Handle number type
  if (type == 'number') {
    final number = property['number'];
    if (number == null) return null;
    return (number is int) ? number : (number as num).toInt();
  }
  
  // Handle rich_text type (number stored as text)
  if (type == 'rich_text') {
    final text = _extractRichText(property);
    if (text == null || text.isEmpty) return null;
    return int.tryParse(text.trim());
  }
  
  return null;
}

String? _extractUrl(dynamic property) {
  if (property == null) return null;
  return property['url'] as String?;
}

String? _extractDateRange(dynamic property) {
  if (property == null) return null;
  final date = property['date'] as Map<String, dynamic>?;
  if (date == null) return null;
  
  final start = date['start'] as String?;
  final end = date['end'] as String?;
  
  if (start == null) return null;
  if (end == null) return start;
  return '$start → $end';
}

int? _extractRating(dynamic property) {
  final stars = _extractSelect(property);
  if (stars == null || stars.isEmpty) return null;
  
  // Count the star emojis
  final starCount = '⭐'.allMatches(stars).length;
  return starCount > 0 ? starCount : null;
}

String _ratingToStars(int rating) {
  return '⭐️' * rating;
}

Map<String, String?> _extractIcon(dynamic icon) {
  if (icon == null) return {'emoji': null, 'url': null};
  
  final type = icon['type'] as String?;
  
  if (type == 'emoji') {
    return {'emoji': icon['emoji'] as String?, 'url': null};
  }
  
  if (type == 'external') {
    final external = icon['external'] as Map<String, dynamic>?;
    return {'emoji': null, 'url': external?['url'] as String?};
  }
  
  if (type == 'file') {
    final file = icon['file'] as Map<String, dynamic>?;
    return {'emoji': null, 'url': file?['url'] as String?};
  }
  
  return {'emoji': null, 'url': null};
}

String? _extractCover(dynamic cover) {
  if (cover == null) return null;
  
  final type = cover['type'] as String?;
  
  if (type == 'external') {
    final external = cover['external'] as Map<String, dynamic>?;
    return external?['url'] as String?;
  }
  
  if (type == 'file') {
    final file = cover['file'] as Map<String, dynamic>?;
    return file?['url'] as String?;
  }
  
  return null;
}
