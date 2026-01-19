import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/books/domain/entities/book.dart';
import '../../features/books/presentation/pages/books_page.dart';
import '../../features/books/presentation/pages/book_detail_page.dart';
import '../../features/books/presentation/pages/book_form_page.dart';

part 'app_router.g.dart';

/// Route names
abstract class AppRoutes {
  static const String books = '/';
  static const String bookDetail = '/book/:id';
  static const String bookCreate = '/book/create';
  static const String bookEdit = '/book/:id/edit';

  static String bookDetailPath(String id) => '/book/$id';
  static String bookEditPath(String id) => '/book/$id/edit';
}

/// Provider for the app router
@riverpod
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: AppRoutes.books,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.books,
        name: 'books',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const BooksPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.bookDetail,
        name: 'bookDetail',
        pageBuilder: (context, state) {
          final bookId = state.pathParameters['id']!;
          final book = state.extra as Book?;
          return CustomTransitionPage(
            key: state.pageKey,
            child: BookDetailPage(bookId: bookId, book: book),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.bookCreate,
        name: 'bookCreate',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const BookFormPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.bookEdit,
        name: 'bookEdit',
        pageBuilder: (context, state) {
          final book = state.extra as Book;
          return CustomTransitionPage(
            key: state.pageKey,
            child: BookFormPage(book: book),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              );
            },
          );
        },
      ),
    ],
    errorPageBuilder: (context, state) => MaterialPage(
      key: state.pageKey,
      child: Scaffold(
        body: Center(
          child: Text('Página no encontrada: ${state.uri}'),
        ),
      ),
    ),
  );
}
