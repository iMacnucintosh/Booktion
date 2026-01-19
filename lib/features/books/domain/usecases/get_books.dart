import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/book.dart';
import '../repositories/book_repository.dart';

/// Use case for fetching all books
class GetBooks {
  final BookRepository _repository;

  GetBooks(this._repository);

  /// Executes the use case
  /// 
  /// Optionally filters books by [status] and/or [searchQuery]
  Future<Either<Failure, List<Book>>> call({
    BookStatus? status,
    String? searchQuery,
  }) async {
    final result = await _repository.getBooks();
    
    return result.map((books) {
      var filteredBooks = books;
      
      // Filter by status if provided
      if (status != null) {
        filteredBooks = filteredBooks
            .where((book) => book.estado == status)
            .toList();
      }
      
      // Filter by search query if provided
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        filteredBooks = filteredBooks.where((book) {
          return book.nombre.toLowerCase().contains(query) ||
              book.autor.toLowerCase().contains(query) ||
              (book.serie?.toLowerCase().contains(query) ?? false);
        }).toList();
      }
      
      // Sort by position (books being read first, then by position)
      filteredBooks.sort((a, b) {
        // Reading books first
        if (a.isReading && !b.isReading) return -1;
        if (!a.isReading && b.isReading) return 1;
        
        // Then by position
        final posA = a.posicion ?? 999;
        final posB = b.posicion ?? 999;
        return posA.compareTo(posB);
      });
      
      return filteredBooks;
    });
  }
}
