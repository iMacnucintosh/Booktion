import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/author.dart';

part 'author_model.freezed.dart';
part 'author_model.g.dart';

/// Data model for Author - handles Notion API JSON conversion
@freezed
class AuthorModel with _$AuthorModel {
  const AuthorModel._();

  const factory AuthorModel({
    required String id,
    required String nombre,
    String? iconUrl,
  }) = _AuthorModel;

  /// Creates AuthorModel from Notion page JSON response
  factory AuthorModel.fromNotionJson(Map<String, dynamic> json) {
    final properties = json['properties'] as Map<String, dynamic>?;
    final icon = json['icon'];
    
    // Extract name from title property (Nombre)
    String nombre = '';
    if (properties != null) {
      final nombreProp = properties['Nombre'] ?? properties['Name'] ?? properties['title'];
      if (nombreProp != null) {
        final titleList = nombreProp['title'] as List?;
        if (titleList != null && titleList.isNotEmpty) {
          nombre = (titleList[0]['plain_text'] as String?) ?? '';
        }
      }
    }
    
    // Extract icon URL (author photo)
    String? iconUrl;
    if (icon != null) {
      final type = icon['type'] as String?;
      if (type == 'external') {
        final external = icon['external'] as Map<String, dynamic>?;
        iconUrl = external?['url'] as String?;
      } else if (type == 'file') {
        final file = icon['file'] as Map<String, dynamic>?;
        iconUrl = file?['url'] as String?;
      }
    }
    
    return AuthorModel(
      id: json['id'] as String,
      nombre: nombre,
      iconUrl: iconUrl,
    );
  }

  /// Converts to domain entity
  Author toEntity() {
    return Author(
      id: id,
      nombre: nombre,
      iconUrl: iconUrl,
    );
  }

  /// Creates AuthorModel from domain entity
  factory AuthorModel.fromEntity(Author author) {
    return AuthorModel(
      id: author.id,
      nombre: author.nombre,
      iconUrl: author.iconUrl,
    );
  }

  factory AuthorModel.fromJson(Map<String, dynamic> json) =>
      _$AuthorModelFromJson(json);
}
