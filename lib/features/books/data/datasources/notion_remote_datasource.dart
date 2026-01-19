import 'package:dio/dio.dart';

import '../../../../core/config/env_config.dart';
import '../../../../core/error/exceptions.dart';
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

  NotionRemoteDataSourceImpl(this._dio);

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
      return results.map((json) => BookModel.fromNotionJson(json)).toList();
    } on DioException catch (e) {
      throw e.error ?? ServerException(message: e.message ?? 'Error desconocido');
    }
  }

  @override
  Future<BookModel> getBookById(String id) async {
    try {
      final response = await _dio.get('/pages/$id');
      return BookModel.fromNotionJson(response.data);
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
