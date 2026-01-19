import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/book.dart';

/// A chip widget that displays the book's reading status
class StatusChip extends StatelessWidget {
  final BookStatus status;
  final bool isSelected;
  final VoidCallback? onTap;

  const StatusChip({
    super.key,
    required this.status,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? _getStatusColor(status) : _getStatusColor(status).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _getStatusColor(status),
            width: isSelected ? 0 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getStatusIcon(status),
              size: 14,
              color: isSelected ? Colors.white : _getStatusColor(status),
            ),
            const SizedBox(width: 6),
            Text(
              status.displayName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : _getStatusColor(status),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(BookStatus status) {
    switch (status) {
      case BookStatus.pendiente:
        return AppColors.statusPending;
      case BookStatus.enCurso:
        return AppColors.statusReading;
      case BookStatus.terminado:
        return AppColors.statusCompleted;
    }
  }

  IconData _getStatusIcon(BookStatus status) {
    switch (status) {
      case BookStatus.pendiente:
        return Icons.schedule_rounded;
      case BookStatus.enCurso:
        return Icons.auto_stories_rounded;
      case BookStatus.terminado:
        return Icons.check_circle_rounded;
    }
  }
}

/// A compact version of the status chip for use in lists
class StatusIndicator extends StatelessWidget {
  final BookStatus status;

  const StatusIndicator({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: _getStatusColor(status),
        shape: BoxShape.circle,
      ),
    );
  }

  Color _getStatusColor(BookStatus status) {
    switch (status) {
      case BookStatus.pendiente:
        return AppColors.statusPending;
      case BookStatus.enCurso:
        return AppColors.statusReading;
      case BookStatus.terminado:
        return AppColors.statusCompleted;
    }
  }
}
