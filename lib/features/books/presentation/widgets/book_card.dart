import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/book.dart';
import 'rating_stars.dart';
import 'status_chip.dart';

/// A card widget that displays book information in a list
class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback? onTap;

  const BookCard({
    super.key,
    required this.book,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // RepaintBoundary isolates this widget's painting from the rest of the tree
    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Book icon/emoji
                  _buildBookIcon(context),
                  const SizedBox(width: 12),

                  // Book info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          book.nombre,
                          style: theme.textTheme.titleLarge,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),

                        // Authors with photos
                        _buildAuthors(context),

                        // Series (if available)
                        if (book.serie != null && book.serie!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            book.serie!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],

                        const SizedBox(height: 8),

                        // Bottom row: Rating and tags
                        Row(
                          children: [
                            if (book.valoracion != null) ...[
                              RatingBadge(rating: book.valoracion),
                              const SizedBox(width: 8),
                            ],
                            if (book.etiquetas.isNotEmpty)
                              Expanded(
                                child: _buildTags(context),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Reading indicator - bottom right
            if (book.estado == BookStatus.enCurso)
              Positioned(
                right: 8,
                bottom: 8,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: AppColors.statusReading,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_stories_rounded,
                    color: Colors.white,
                    size: 11,
                  ),
                ),
              ),

            // Completed indicator - bottom right
            if (book.estado == BookStatus.terminado)
              Positioned(
                right: 8,
                bottom: 8,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: AppColors.statusCompleted,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildAuthors(BuildContext context) {
    final theme = Theme.of(context);
    
    return Text(
      book.autor.isNotEmpty ? book.autor : 'Autor desconocido',
      style: theme.textTheme.bodyMedium,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTags(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: book.etiquetas.take(2).map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            tag,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryLight,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBookIcon(BuildContext context) {
    final theme = Theme.of(context);
    const double iconSize = 56;
    const double borderRadius = 10;

    // Show emoji if available
    if (book.iconEmoji != null) {
      return Container(
        width: iconSize,
        height: iconSize,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Center(
          child: Text(
            book.iconEmoji!,
            style: const TextStyle(fontSize: 32),
          ),
        ),
      );
    }

    // Show image if available
    if (book.iconUrl != null) {
      return Container(
        width: iconSize,
        height: iconSize,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          image: DecorationImage(
            image: NetworkImage(book.iconUrl!),
            fit: BoxFit.cover,
            onError: (_, __) {},
          ),
        ),
      );
    }

    // Default icon with status indicator
    return Stack(
      children: [
        _buildDefaultIcon(context),
        Positioned(
          right: 0,
          bottom: 0,
          child: StatusIndicator(status: book.estado),
        ),
      ],
    );
  }

  Widget _buildDefaultIcon(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Icons.menu_book_rounded,
        color: theme.colorScheme.outline,
        size: 28,
      ),
    );
  }
}
