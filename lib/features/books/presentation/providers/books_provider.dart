import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/notion_remote_datasource.dart';
import '../../data/repositories/book_repository_impl.dart';
import '../../domain/entities/author.dart';
import '../../domain/entities/book.dart';
import '../../domain/repositories/book_repository.dart';
import '../../domain/usecases/create_book.dart';
import '../../domain/usecases/delete_book.dart';
import '../../domain/usecases/get_book_by_id.dart';
import '../../domain/usecases/get_books.dart';
import '../../domain/usecases/update_book.dart';

part 'books_provider.g.dart';

// ==================== Data Layer Providers ====================

@riverpod
NotionRemoteDataSource notionRemoteDataSource(Ref ref) {
  final dio = ref.watch(dioClientProvider);
  return NotionRemoteDataSourceImpl(dio);
}

@riverpod
BookRepository bookRepository(Ref ref) {
  final dataSource = ref.watch(notionRemoteDataSourceProvider);
  return BookRepositoryImpl(dataSource);
}

// ==================== Use Case Providers ====================

@riverpod
GetBooks getBooks(Ref ref) {
  return GetBooks(ref.watch(bookRepositoryProvider));
}

@riverpod
GetBookById getBookById(Ref ref) {
  return GetBookById(ref.watch(bookRepositoryProvider));
}

@riverpod
CreateBook createBook(Ref ref) {
  return CreateBook(ref.watch(bookRepositoryProvider));
}

@riverpod
UpdateBook updateBook(Ref ref) {
  return UpdateBook(ref.watch(bookRepositoryProvider));
}

@riverpod
DeleteBook deleteBook(Ref ref) {
  return DeleteBook(ref.watch(bookRepositoryProvider));
}

// ==================== Authors Providers ====================

/// Provider for fetching all authors
@riverpod
Future<List<Author>> authorsList(Ref ref) async {
  final dataSource = ref.watch(notionRemoteDataSourceProvider);
  final authorModels = await dataSource.getAllAuthors();
  return authorModels.map((m) => m.toEntity()).toList();
}

/// Notifier for creating a new author
@riverpod
class CreateAuthorNotifier extends _$CreateAuthorNotifier {
  @override
  AsyncValue<Author?> build() => const AsyncValue.data(null);

  Future<Author?> create(String nombre) async {
    state = const AsyncValue.loading();
    try {
      final dataSource = ref.read(notionRemoteDataSourceProvider);
      final authorModel = await dataSource.createAuthor(nombre);
      final author = authorModel.toEntity();
      state = AsyncValue.data(author);
      // Invalidate the authors list to refresh it
      ref.invalidate(authorsListProvider);
      return author;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}

// ==================== State Providers ====================

/// Sort options for books list
enum BookSortOption {
  nameAsc('Nombre (A-Z)'),
  nameDesc('Nombre (Z-A)'),
  authorAsc('Autor (A-Z)'),
  authorDesc('Autor (Z-A)'),
  ratingDesc('Mejor valorados'),
  ratingAsc('Peor valorados'),
  positionAsc('Posición (menor)'),
  positionDesc('Posición (mayor)'),
  recentFirst('Recientes primero'),
  oldestFirst('Antiguos primero');

  final String displayName;
  const BookSortOption(this.displayName);
}

/// Sort order state
@riverpod
class BooksSortOrder extends _$BooksSortOrder {
  @override
  BookSortOption build() => BookSortOption.recentFirst;

  void setSort(BookSortOption option) {
    state = option;
  }
}

/// Filter state for books list
@riverpod
class BooksFilter extends _$BooksFilter {
  @override
  BookStatus? build() => null;

  void setFilter(BookStatus? status) {
    state = status;
  }

  void clearFilter() {
    state = null;
  }
}

/// Search query state
@riverpod
class BooksSearchQuery extends _$BooksSearchQuery {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }

  void clearQuery() {
    state = '';
  }
}

/// Provider for fetching books list with filters and sorting
@riverpod
Future<List<Book>> booksList(Ref ref) async {
  final getBooks = ref.watch(getBooksProvider);
  final filter = ref.watch(booksFilterProvider);
  final searchQuery = ref.watch(booksSearchQueryProvider);
  final sortOption = ref.watch(booksSortOrderProvider);

  final result = await getBooks(
    status: filter,
    searchQuery: searchQuery.isNotEmpty ? searchQuery : null,
  );

  return result.fold(
    (failure) => throw Exception(failure.displayMessage),
    (books) => _sortBooks(books, sortOption),
  );
}

/// Sort books based on the selected option
List<Book> _sortBooks(List<Book> books, BookSortOption option) {
  final sorted = List<Book>.from(books);

  switch (option) {
    case BookSortOption.nameAsc:
      sorted.sort(
          (a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));
    case BookSortOption.nameDesc:
      sorted.sort(
          (a, b) => b.nombre.toLowerCase().compareTo(a.nombre.toLowerCase()));
    case BookSortOption.authorAsc:
      sorted.sort(
          (a, b) => a.autor.toLowerCase().compareTo(b.autor.toLowerCase()));
    case BookSortOption.authorDesc:
      sorted.sort(
          (a, b) => b.autor.toLowerCase().compareTo(a.autor.toLowerCase()));
    case BookSortOption.ratingDesc:
      sorted.sort((a, b) => (b.valoracion ?? 0).compareTo(a.valoracion ?? 0));
    case BookSortOption.ratingAsc:
      sorted.sort((a, b) => (a.valoracion ?? 0).compareTo(b.valoracion ?? 0));
    case BookSortOption.positionAsc:
      sorted.sort((a, b) => (a.posicion ?? 9999).compareTo(b.posicion ?? 9999));
    case BookSortOption.positionDesc:
      sorted.sort((a, b) => (b.posicion ?? 0).compareTo(a.posicion ?? 0));
    case BookSortOption.recentFirst:
      // Sort by fechaTerminado descending (most recent first)
      sorted.sort(
          (a, b) => (b.fechaTerminado ?? '').compareTo(a.fechaTerminado ?? ''));
    case BookSortOption.oldestFirst:
      sorted.sort((a, b) =>
          (a.fechaTerminado ?? 'zzzz').compareTo(b.fechaTerminado ?? 'zzzz'));
  }

  return sorted;
}

/// Provider for fetching a single book by ID
@riverpod
Future<Book> bookDetail(Ref ref, String id) async {
  final getBookById = ref.watch(getBookByIdProvider);
  final result = await getBookById(id);

  return result.fold(
    (failure) => throw Exception(failure.displayMessage),
    (book) => book,
  );
}

// ==================== Suggestions Providers ====================

/// Provider for unique authors from all books
@riverpod
Future<List<String>> authorSuggestions(Ref ref) async {
  final booksAsync = ref.watch(booksListProvider);
  return booksAsync.when(
    data: (books) {
      final authors = <String>{};
      for (final book in books) {
        // Split by comma in case of multiple authors
        final bookAuthors = book.autor.split(',').map((a) => a.trim());
        authors.addAll(bookAuthors.where((a) => a.isNotEmpty));
      }
      return authors.toList()..sort();
    },
    loading: () => [],
    error: (_, __) => [],
  );
}

/// Provider for unique series from all books
@riverpod
Future<List<String>> seriesSuggestions(Ref ref) async {
  final booksAsync = ref.watch(booksListProvider);
  return booksAsync.when(
    data: (books) {
      final series = <String>{};
      for (final book in books) {
        if (book.serie != null && book.serie!.isNotEmpty) {
          // Split by comma in case of multiple series
          final bookSeries = book.serie!.split(',').map((s) => s.trim());
          series.addAll(bookSeries.where((s) => s.isNotEmpty));
        }
      }
      return series.toList()..sort();
    },
    loading: () => [],
    error: (_, __) => [],
  );
}

/// Provider for unique genres from all books
@riverpod
Future<List<String>> genreSuggestions(Ref ref) async {
  final booksAsync = ref.watch(booksListProvider);
  return booksAsync.when(
    data: (books) {
      final genres = <String>{};
      for (final book in books) {
        genres.addAll(book.generos);
      }
      return genres.toList()..sort();
    },
    loading: () => [],
    error: (_, __) => [],
  );
}

/// Provider for unique tags from all books
@riverpod
Future<List<String>> tagSuggestions(Ref ref) async {
  final booksAsync = ref.watch(booksListProvider);
  return booksAsync.when(
    data: (books) {
      final tags = <String>{};
      for (final book in books) {
        tags.addAll(book.etiquetas);
      }
      return tags.toList()..sort();
    },
    loading: () => [],
    error: (_, __) => [],
  );
}

// ==================== Mutation Notifiers ====================

/// State for book mutations (create, update, delete)
class BookMutationState {
  final bool isLoading;
  final String? error;
  final Book? result;

  const BookMutationState({
    this.isLoading = false,
    this.error,
    this.result,
  });

  BookMutationState copyWith({
    bool? isLoading,
    String? error,
    Book? result,
  }) {
    return BookMutationState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      result: result ?? this.result,
    );
  }
}

/// Notifier for creating books
@riverpod
class CreateBookNotifier extends _$CreateBookNotifier {
  @override
  BookMutationState build() => const BookMutationState();

  Future<bool> create(Book book) async {
    state = const BookMutationState(isLoading: true);

    final createBook = ref.read(createBookProvider);
    final result = await createBook(book);

    return result.fold(
      (failure) {
        state = BookMutationState(error: failure.displayMessage);
        return false;
      },
      (createdBook) {
        state = BookMutationState(result: createdBook);
        // Invalidate the books list to refresh
        ref.invalidate(booksListProvider);
        return true;
      },
    );
  }

  void reset() {
    state = const BookMutationState();
  }
}

/// Notifier for updating books
@riverpod
class UpdateBookNotifier extends _$UpdateBookNotifier {
  @override
  BookMutationState build() => const BookMutationState();

  Future<bool> update(Book book) async {
    state = const BookMutationState(isLoading: true);

    final updateBook = ref.read(updateBookProvider);
    final result = await updateBook(book);

    return result.fold(
      (failure) {
        state = BookMutationState(error: failure.displayMessage);
        return false;
      },
      (updatedBook) {
        state = BookMutationState(result: updatedBook);
        // Invalidate the books list and detail to refresh
        ref.invalidate(booksListProvider);
        ref.invalidate(bookDetailProvider(book.id));
        return true;
      },
    );
  }

  void reset() {
    state = const BookMutationState();
  }
}

/// Notifier for deleting books
@riverpod
class DeleteBookNotifier extends _$DeleteBookNotifier {
  @override
  BookMutationState build() => const BookMutationState();

  Future<bool> delete(String id) async {
    state = const BookMutationState(isLoading: true);

    final deleteBook = ref.read(deleteBookProvider);
    final result = await deleteBook(id);

    return result.fold(
      (failure) {
        state = BookMutationState(error: failure.displayMessage);
        return false;
      },
      (_) {
        state = const BookMutationState();
        // Invalidate the books list to refresh
        ref.invalidate(booksListProvider);
        return true;
      },
    );
  }

  void reset() {
    state = const BookMutationState();
  }
}
