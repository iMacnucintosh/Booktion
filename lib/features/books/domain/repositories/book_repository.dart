import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/book.dart';

/// Abstract repository interface for books
/// 
/// This interface defines the contract for book data operations.
/// Implementations can use different data sources (Notion, local DB, etc.)
abstract class BookRepository {
  /// Fetches all books from the data source
  /// 
  /// Returns [Either] with [Failure] on error or [List<Book>] on success
  Future<Either<Failure, List<Book>>> getBooks();

  /// Fetches a single book by its ID
  /// 
  /// Returns [Either] with [Failure] on error or [Book] on success
  Future<Either<Failure, Book>> getBookById(String id);

  /// Creates a new book in the data source
  /// 
  /// Returns [Either] with [Failure] on error or the created [Book] on success
  Future<Either<Failure, Book>> createBook(Book book);

  /// Updates an existing book in the data source
  /// 
  /// Returns [Either] with [Failure] on error or the updated [Book] on success
  Future<Either<Failure, Book>> updateBook(Book book);

  /// Deletes a book from the data source
  /// 
  /// Returns [Either] with [Failure] on error or [Unit] on success
  Future<Either<Failure, Unit>> deleteBook(String id);
}
