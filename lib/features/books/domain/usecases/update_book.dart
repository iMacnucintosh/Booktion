import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/book.dart';
import '../repositories/book_repository.dart';

/// Use case for updating an existing book
class UpdateBook {
  final BookRepository _repository;

  UpdateBook(this._repository);

  /// Executes the use case
  Future<Either<Failure, Book>> call(Book book) async {
    // Validate required fields
    if (book.id.isEmpty) {
      return left(const Failure.unknown(message: 'El ID del libro es requerido'));
    }
    if (book.nombre.trim().isEmpty) {
      return left(const Failure.unknown(message: 'El nombre del libro es requerido'));
    }
    if (book.autor.trim().isEmpty) {
      return left(const Failure.unknown(message: 'El autor del libro es requerido'));
    }
    
    return _repository.updateBook(book);
  }
}
