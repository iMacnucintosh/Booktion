import 'package:freezed_annotation/freezed_annotation.dart';

part 'author.freezed.dart';

/// Author entity - represents a book author from Notion
@freezed
class Author with _$Author {
  const Author._();

  const factory Author({
    required String id,
    required String nombre,
    String? iconUrl,  // Author photo from Notion page icon
  }) = _Author;

  /// Display name for the author
  String get displayName => nombre;
}
