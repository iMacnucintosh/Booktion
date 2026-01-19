import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/book.dart';
import '../repositories/book_repository.dart';

/// Use case for fetching a single book by ID
class GetBookById {
  final BookRepository _repository;

  GetBookById(this._repository);

  /// Executes the use case
  Future<Either<Failure, Book>> call(String id) async {
    return _repository.getBookById(id);
  }
}
