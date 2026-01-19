import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/book_repository.dart';

/// Use case for deleting a book
class DeleteBook {
  final BookRepository _repository;

  DeleteBook(this._repository);

  /// Executes the use case
  Future<Either<Failure, Unit>> call(String id) async {
    if (id.isEmpty) {
      return left(const Failure.unknown(message: 'El ID del libro es requerido'));
    }
    
    return _repository.deleteBook(id);
  }
}
