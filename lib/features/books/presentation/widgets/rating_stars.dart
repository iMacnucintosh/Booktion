import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// A widget that displays a star rating
class RatingStars extends StatelessWidget {
  final int? rating;
  final double size;
  final bool interactive;
  final ValueChanged<int>? onRatingChanged;

  const RatingStars({
    super.key,
    this.rating,
    this.size = 16,
    this.interactive = false,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (rating == null && !interactive) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starNumber = index + 1;
        final isActive = rating != null && starNumber <= rating!;

        return GestureDetector(
          onTap: interactive ? () => onRatingChanged?.call(starNumber) : null,
          child: Padding(
            padding: EdgeInsets.only(right: index < 4 ? 2 : 0),
            child: Icon(
              isActive ? Icons.star_rounded : Icons.star_outline_rounded,
              size: size,
              color: isActive ? AppColors.starActive : theme.colorScheme.outlineVariant,
            ),
          ),
        );
      }),
    );
  }
}

/// A compact display of the rating (e.g., "4.0 ⭐")
class RatingBadge extends StatelessWidget {
  final int? rating;

  const RatingBadge({super.key, this.rating});

  @override
  Widget build(BuildContext context) {
    if (rating == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.starActive.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_rounded,
            size: 14,
            color: AppColors.starActive,
          ),
          const SizedBox(width: 4),
          Text(
            '$rating',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.starActive,
            ),
          ),
        ],
      ),
    );
  }
}
