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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: book.isReading
              ? Border.all(
                  color: AppColors.statusReading.withValues(alpha: 0.5),
                  width: 1.5)
              : null,
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

                        // Author
                        Text(
                          book.autor,
                          style: theme.textTheme.bodyMedium,
                        ),

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
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.network(
          book.iconUrl!,
          fit: BoxFit.cover,
          width: iconSize,
          height: iconSize,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  color: AppColors.primary,
                ),
              ),
            );
          },
          errorBuilder: (_, __, ___) => _buildDefaultIcon(context),
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
