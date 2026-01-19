import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/book.dart';
import 'book_card.dart';

/// A list widget that displays books with pull-to-refresh
class BookList extends StatelessWidget {
  final List<Book> books;
  final Future<void> Function()? onRefresh;
  final void Function(Book book)? onBookTap;

  const BookList({
    super.key,
    required this.books,
    this.onRefresh,
    this.onBookTap,
  });

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) {
      return const _EmptyState();
    }

    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: onRefresh ?? () async {},
      color: AppColors.primary,
      backgroundColor: theme.colorScheme.surface,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return BookCard(
            book: book,
            onTap: () => onBookTap?.call(book),
          );
        },
      ),
    );
  }
}

/// Empty state widget when no books are found
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedColor = theme.colorScheme.outline;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book_rounded,
            size: 80,
            color: mutedColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay libros',
            style: theme.textTheme.headlineSmall?.copyWith(color: mutedColor),
          ),
          const SizedBox(height: 8),
          Text(
            'Añade tu primer libro tocando el botón +',
            style: theme.textTheme.bodyMedium?.copyWith(color: mutedColor),
          ),
        ],
      ),
    );
  }
}

/// Skeleton loading widget for books list
class BookListSkeleton extends StatelessWidget {
  const BookListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Shimmer.fromColors(
      baseColor: theme.colorScheme.surfaceContainerHighest,
      highlightColor: theme.colorScheme.surface,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        itemBuilder: (context, index) {
          return _BookCardSkeleton(theme: theme);
        },
      ),
    );
  }
}

class _BookCardSkeleton extends StatelessWidget {
  final ThemeData theme;

  const _BookCardSkeleton({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon skeleton
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 12),

          // Content skeleton
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 18,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 14,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      height: 20,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 20,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
