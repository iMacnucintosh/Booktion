import 'package:dio/dio.dart';

import '../../../../core/config/env_config.dart';
import '../../../../core/error/exceptions.dart';
import '../models/author_model.dart';
import '../models/book_model.dart';

/// Remote data source for Notion API
abstract class NotionRemoteDataSource {
  /// Fetches all books from Notion database
  Future<List<BookModel>> getBooks();

  /// Fetches a single book by ID
  Future<BookModel> getBookById(String id);

  /// Creates a new book page in Notion
  Future<BookModel> createBook(BookModel book);

  /// Updates an existing book page in Notion
  Future<BookModel> updateBook(BookModel book);

  /// Archives (deletes) a book page in Notion
  Future<void> deleteBook(String id);
}

/// Implementation of Notion remote data source
class NotionRemoteDataSourceImpl implements NotionRemoteDataSource {
  final Dio _dio;
  
  // Cache for authors to avoid repeated API calls
  final Map<String, AuthorModel> _authorCache = {};

  NotionRemoteDataSourceImpl(this._dio);

  /// Fetches author data from Notion by page ID
  Future<AuthorModel> _getAuthor(String authorId) async {
    // Check cache first
    if (_authorCache.containsKey(authorId)) {
      return _authorCache[authorId]!;
    }
    
    try {
      final response = await _dio.get('/pages/$authorId');
      final author = AuthorModel.fromNotionJson(response.data);
      _authorCache[authorId] = author;
      return author;
    } catch (e) {
      // Return a placeholder author if fetch fails
      return AuthorModel(id: authorId, nombre: 'Autor desconocido');
    }
  }

  /// Resolves all author IDs to full author data
  Future<List<AuthorModel>> _resolveAuthors(List<String> authorIds) async {
    if (authorIds.isEmpty) return [];
    
    final futures = authorIds.map((id) => _getAuthor(id));
    return Future.wait(futures);
  }

  /// Enriches a book with resolved author data
  Future<BookModel> _enrichBookWithAuthors(BookModel book) async {
    if (book.autorIds.isEmpty) return book;
    final authors = await _resolveAuthors(book.autorIds);
    return book.withAuthors(authors);
  }

  @override
  Future<List<BookModel>> getBooks() async {
    try {
      final response = await _dio.post(
        '/databases/${EnvConfig.notionDatabaseId}/query',
        data: {
          'sorts': [
            {
              'property': 'Posición',
              'direction': 'ascending',
            }
          ],
        },
      );

      final results = response.data['results'] as List;
      final books = results.map((json) => BookModel.fromNotionJson(json)).toList();
      
      // Resolve authors for all books
      final enrichedBooks = await Future.wait(
        books.map((book) => _enrichBookWithAuthors(book)),
      );
      
      return enrichedBooks;
    } on DioException catch (e) {
      throw e.error ?? ServerException(message: e.message ?? 'Error desconocido');
    }
  }

  @override
  Future<BookModel> getBookById(String id) async {
    try {
      final response = await _dio.get('/pages/$id');
      final book = BookModel.fromNotionJson(response.data);
      return _enrichBookWithAuthors(book);
    } on DioException catch (e) {
      throw e.error ?? ServerException(message: e.message ?? 'Error desconocido');
    }
  }

  @override
  Future<BookModel> createBook(BookModel book) async {
    try {
      final response = await _dio.post(
        '/pages',
        data: {
          'parent': {
            'database_id': EnvConfig.notionDatabaseId,
          },
          'properties': book.toNotionProperties(),
        },
      );

      return BookModel.fromNotionJson(response.data);
    } on DioException catch (e) {
      throw e.error ?? ServerException(message: e.message ?? 'Error desconocido');
    }
  }

  @override
  Future<BookModel> updateBook(BookModel book) async {
    try {
      final response = await _dio.patch(
        '/pages/${book.id}',
        data: {
          'properties': book.toNotionProperties(),
        },
      );

      return BookModel.fromNotionJson(response.data);
    } on DioException catch (e) {
      throw e.error ?? ServerException(message: e.message ?? 'Error desconocido');
    }
  }

  @override
  Future<void> deleteBook(String id) async {
    try {
      // Notion doesn't truly delete pages, it archives them
      await _dio.patch(
        '/pages/$id',
        data: {
          'archived': true,
        },
      );
    } on DioException catch (e) {
      throw e.error ?? ServerException(message: e.message ?? 'Error desconocido');
    }
  }
}
