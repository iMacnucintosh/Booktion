import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/book.dart';
import '../providers/books_provider.dart';
import '../widgets/book_list.dart';
import '../widgets/status_chip.dart';

/// Main page displaying the list of books
class BooksPage extends ConsumerStatefulWidget {
  const BooksPage({super.key});

  @override
  ConsumerState<BooksPage> createState() => _BooksPageState();
}

class _BooksPageState extends ConsumerState<BooksPage> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final booksAsync = ref.watch(booksListProvider);
    final currentFilter = ref.watch(booksFilterProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Bar
            _buildAppBar(context),

            // Filter chips
            _buildFilterChips(currentFilter),

            // Books list
            Expanded(
              child: booksAsync.when(
                data: (books) => BookList(
                  books: books,
                  onRefresh: () => ref.refresh(booksListProvider.future),
                  onBookTap: (book) => _navigateToDetail(book),
                ),
                loading: () => const BookListSkeleton(),
                error: (error, stack) => _buildErrorState(error.toString()),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.bookCreate),
        icon: const Icon(Icons.add),
        label: const Text('Añadir'),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          if (!_isSearching) ...[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booktion',
                    style: theme.textTheme.displaySmall,
                  ),
                  Text(
                    'Tu biblioteca de Notion',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() => _isSearching = true);
              },
              icon: const Icon(Icons.search_rounded),
            ),
          ] else ...[
            Expanded(
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Buscar libros...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: IconButton(
                    onPressed: () {
                      _searchController.clear();
                      ref.read(booksSearchQueryProvider.notifier).clearQuery();
                      setState(() => _isSearching = false);
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
                onChanged: (value) {
                  ref.read(booksSearchQueryProvider.notifier).setQuery(value);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChips(BookStatus? currentFilter) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // "All" filter
          GestureDetector(
            onTap: () {
              ref.read(booksFilterProvider.notifier).clearFilter();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: currentFilter == null
                    ? AppColors.primary
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Todos',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: currentFilter == null
                      ? Colors.white
                      : theme.textTheme.bodyMedium?.color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Status filters
          ...BookStatus.values.map((status) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: StatusChip(
                status: status,
                isSelected: currentFilter == status,
                onTap: () {
                  if (currentFilter == status) {
                    ref.read(booksFilterProvider.notifier).clearFilter();
                  } else {
                    ref.read(booksFilterProvider.notifier).setFilter(status);
                  }
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppColors.error.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar los libros',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.refresh(booksListProvider.future),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(Book book) {
    context.push(AppRoutes.bookDetailPath(book.id), extra: book);
  }
}
