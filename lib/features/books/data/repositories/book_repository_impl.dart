import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/book.dart';
import '../../domain/repositories/book_repository.dart';
import '../datasources/notion_remote_datasource.dart';
import '../models/book_model.dart';

/// Implementation of BookRepository using Notion as data source
class BookRepositoryImpl implements BookRepository {
  final NotionRemoteDataSource _remoteDataSource;

  BookRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<Book>>> getBooks() async {
    try {
      final bookModels = await _remoteDataSource.getBooks();
      final books = bookModels.map((model) => model.toEntity()).toList();
      return right(books);
    } on ServerException catch (e) {
      return left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return left(Failure.network(message: e.message));
    } on NotFoundException catch (e) {
      return left(Failure.notFound(message: e.message));
    } on UnauthorizedException catch (e) {
      return left(Failure.unauthorized(message: e.message));
    } catch (e) {
      return left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Book>> getBookById(String id) async {
    try {
      final bookModel = await _remoteDataSource.getBookById(id);
      return right(bookModel.toEntity());
    } on ServerException catch (e) {
      return left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return left(Failure.network(message: e.message));
    } on NotFoundException catch (e) {
      return left(Failure.notFound(message: e.message));
    } on UnauthorizedException catch (e) {
      return left(Failure.unauthorized(message: e.message));
    } catch (e) {
      return left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Book>> createBook(Book book) async {
    try {
      final bookModel = BookModel.fromEntity(book);
      final createdModel = await _remoteDataSource.createBook(bookModel);
      return right(createdModel.toEntity());
    } on ServerException catch (e) {
      return left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return left(Failure.network(message: e.message));
    } on UnauthorizedException catch (e) {
      return left(Failure.unauthorized(message: e.message));
    } catch (e) {
      return left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Book>> updateBook(Book book) async {
    try {
      final bookModel = BookModel.fromEntity(book);
      final updatedModel = await _remoteDataSource.updateBook(bookModel);
      return right(updatedModel.toEntity());
    } on ServerException catch (e) {
      return left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return left(Failure.network(message: e.message));
    } on NotFoundException catch (e) {
      return left(Failure.notFound(message: e.message));
    } on UnauthorizedException catch (e) {
      return left(Failure.unauthorized(message: e.message));
    } catch (e) {
      return left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteBook(String id) async {
    try {
      await _remoteDataSource.deleteBook(id);
      return right(unit);
    } on ServerException catch (e) {
      return left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return left(Failure.network(message: e.message));
    } on NotFoundException catch (e) {
      return left(Failure.notFound(message: e.message));
    } on UnauthorizedException catch (e) {
      return left(Failure.unauthorized(message: e.message));
    } catch (e) {
      return left(Failure.unknown(message: e.toString()));
    }
  }
}
