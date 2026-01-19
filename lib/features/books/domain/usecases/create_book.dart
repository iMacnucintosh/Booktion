import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/book.dart';
import '../repositories/book_repository.dart';

/// Use case for creating a new book
class CreateBook {
  final BookRepository _repository;

  CreateBook(this._repository);

  /// Executes the use case
  Future<Either<Failure, Book>> call(Book book) async {
    // Validate required fields
    if (book.nombre.trim().isEmpty) {
      return left(const Failure.unknown(message: 'El nombre del libro es requerido'));
    }
    if (book.autor.trim().isEmpty) {
      return left(const Failure.unknown(message: 'El autor del libro es requerido'));
    }
    
    return _repository.createBook(book);
  }
}
