import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/book.dart';
import '../providers/books_provider.dart';
import '../widgets/rating_stars.dart';
import '../widgets/status_chip.dart';

/// Page displaying detailed information about a book
class BookDetailPage extends ConsumerWidget {
  final String bookId;
  final Book? book;

  const BookDetailPage({
    super.key,
    required this.bookId,
    this.book,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Always watch the provider to get fresh data after updates
    final bookAsync = ref.watch(bookDetailProvider(bookId));

    return Scaffold(
      body: bookAsync.when(
        data: (book) => _BookDetailContent(book: book),
        loading: () {
          // Show cached book while loading, or spinner if no cache
          if (book != null) {
            return _BookDetailContent(book: book!);
          }
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        },
        error: (error, _) => _buildErrorState(context, ref, error.toString()),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, String error) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar el libro',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error,
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () =>
                          ref.refresh(bookDetailProvider(bookId).future),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookDetailContent extends ConsumerStatefulWidget {
  final Book book;

  const _BookDetailContent({required this.book});

  @override
  ConsumerState<_BookDetailContent> createState() => _BookDetailContentState();
}

class _BookDetailContentState extends ConsumerState<_BookDetailContent> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  Book get book => widget.book;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasCover = book.coverUrl != null;
    final coverHeight = hasCover ? 350.0 : 220.0;
    final topPadding = MediaQuery.of(context).padding.top;

    // Calculate parallax and scale effects
    final parallaxOffset = _scrollOffset * 0.5;
    final iconScale = (1 - (_scrollOffset / 300).clamp(0, 0.3)).toDouble();
    final iconOffset = (_scrollOffset * 0.3).clamp(0, 50).toDouble();

    return Stack(
      children: [
        // Background cover with parallax
        Positioned(
          top: -parallaxOffset,
          left: 0,
          right: 0,
          height: coverHeight + 100,
          child: _buildCoverImage(context, hasCover),
        ),

        // Scrollable content
        CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Transparent space for cover
            SliverToBoxAdapter(
              child: SizedBox(height: coverHeight - 50),
            ),

            // Content card with floating icon
            SliverToBoxAdapter(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Card content
                  Container(
                    margin: const EdgeInsets.only(top: 45),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title row with space for icon
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Space for the floating icon
                              const SizedBox(width: 100),
                              // Title and author
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      book.nombre,
                                      style: theme.textTheme.headlineMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    // Series if available
                                    if (book.serie != null &&
                                        book.serie!.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        book.serie!,
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          fontStyle: FontStyle.italic,
                                          color: theme.colorScheme.outline,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Author section with status chip
                          Row(
                            children: [
                              // Author - prominent display
                              if (book.autores.isNotEmpty ||
                                  book.autor.isNotEmpty)
                                Expanded(
                                  child: _buildAuthorSection(context),
                                )
                              else
                                const Spacer(),
                              // Status chip
                              StatusChip(status: book.estado, isSelected: true),
                            ],
                          ),

                          // Rating
                          if (book.valoracion != null) ...[
                            const SizedBox(height: 20),
                            RatingStars(rating: book.valoracion, size: 24),
                          ],

                          const SizedBox(height: 28),

                          // Info cards
                          _buildInfoSection(context),

                          // Reading period (stepper style)
                          if (book.fechaTerminado != null &&
                              book.fechaTerminado!.isNotEmpty) ...[
                            const SizedBox(height: 28),
                            _buildPeriodSection(context),
                          ],

                          // Tags
                          if (book.etiquetas.isNotEmpty) ...[
                            const SizedBox(height: 28),
                            _buildTagsSection(context),
                          ],

                          // Genres
                          if (book.generos.isNotEmpty) ...[
                            const SizedBox(height: 28),
                            _buildGenresSection(context),
                          ],

                          // Summary
                          if (book.resumen != null &&
                              book.resumen!.isNotEmpty) ...[
                            const SizedBox(height: 28),
                            _buildSummarySection(context),
                          ],

                          // URL
                          if (book.url != null && book.url!.isNotEmpty) ...[
                            const SizedBox(height: 28),
                            _buildUrlSection(context),
                          ],

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),

                  // Floating icon positioned between cover and card
                  Positioned(
                    top: 0,
                    left: 20,
                    child: Transform.translate(
                      offset: Offset(0, -iconOffset),
                      child: Transform.scale(
                        scale: iconScale,
                        alignment: Alignment.topLeft,
                        child: _buildFloatingIcon(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // Floating back button
        Positioned(
          top: topPadding + 8,
          left: 8,
          child: _buildFloatingButton(
            context,
            icon: Icons.arrow_back_rounded,
            onTap: () => context.pop(),
            hasCover: hasCover,
          ),
        ),

        // Floating options button
        Positioned(
          top: topPadding + 8,
          right: 8,
          child: _buildFloatingButton(
            context,
            icon: Icons.more_vert_rounded,
            onTap: () => _showOptionsMenu(context, ref),
            hasCover: hasCover,
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
    required bool hasCover,
  }) {
    final theme = Theme.of(context);
    final bgOpacity = (_scrollOffset / 100).clamp(0.0, 0.9);
    final showDarkBg = hasCover && _scrollOffset < 100;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: showDarkBg
              ? Colors.black.withValues(alpha: 0.4)
              : theme.colorScheme.surface.withValues(alpha: bgOpacity),
          shape: BoxShape.circle,
          boxShadow: _scrollOffset > 50
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: showDarkBg ? Colors.white : theme.colorScheme.onSurface,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildCoverImage(BuildContext context, bool hasCover) {
    final theme = Theme.of(context);

    if (hasCover) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            book.coverUrl!,
            fit: BoxFit.cover,
            // Limit decoded image size for better performance
            cacheWidth: 800,
            errorBuilder: (_, __, ___) => _buildGradientBackground(context),
          ),
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.transparent,
                  theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
                  theme.scaffoldBackgroundColor,
                ],
                stops: const [0.0, 0.3, 0.75, 1.0],
              ),
            ),
          ),
        ],
      );
    }

    return _buildGradientBackground(context);
  }

  Widget _buildGradientBackground(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.6),
            AppColors.primaryDark.withValues(alpha: 0.4),
            theme.scaffoldBackgroundColor,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildFloatingIcon(BuildContext context) {
    final theme = Theme.of(context);
    const double iconSize = 90;
    const double borderRadius = 20;

    Widget iconContent;

    if (book.iconEmoji != null) {
      iconContent = Center(
        child: Text(
          book.iconEmoji!,
          style: const TextStyle(fontSize: 48),
        ),
      );
    } else if (book.iconUrl != null) {
      iconContent = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.network(
          book.iconUrl!,
          fit: BoxFit.cover,
          width: iconSize,
          height: iconSize,
          // Limit decoded image size for better performance
          cacheWidth: (iconSize * 2).toInt(),
          cacheHeight: (iconSize * 2).toInt(),
          errorBuilder: (_, __, ___) => const Icon(
            Icons.menu_book_rounded,
            color: AppColors.primary,
            size: 40,
          ),
        ),
      );
    } else {
      iconContent = const Icon(
        Icons.menu_book_rounded,
        color: AppColors.primary,
        size: 40,
      );
    }

    return Container(
      width: iconSize,
      height: iconSize,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: iconContent,
    );
  }

  Widget _buildAuthorSection(BuildContext context) {
    final theme = Theme.of(context);

    // If no authors with data, just show the text
    if (book.autores.isEmpty) {
      return Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              size: 24,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              book.autor,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    }

    // Show authors with photos
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: book.autores.map((author) {
        return _buildAuthorCard(context, author);
      }).toList(),
    );
  }

  Widget _buildAuthorCard(BuildContext context, dynamic author) {
    final theme = Theme.of(context);
    const double avatarSize = 48;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Author photo
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: 0.15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: author.iconUrl != null
              ? Image.network(
                  author.iconUrl!,
                  fit: BoxFit.cover,
                  width: avatarSize,
                  height: avatarSize,
                  cacheWidth: (avatarSize * 2).toInt(),
                  cacheHeight: (avatarSize * 2).toInt(),
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.person,
                    size: 24,
                    color: AppColors.primary,
                  ),
                )
              : const Icon(
                  Icons.person,
                  size: 24,
                  color: AppColors.primary,
                ),
        ),
        const SizedBox(width: 12),
        // Author name
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              author.nombre,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Autor',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    final theme = Theme.of(context);
    final items = <_InfoItem>[];

    if (book.numPaginas != null) {
      items.add(_InfoItem(
        icon: Icons.auto_stories_rounded,
        label: 'Páginas',
        value: '${book.numPaginas}',
      ));
    }

    if (book.posicion != null) {
      items.add(_InfoItem(
        icon: Icons.format_list_numbered_rounded,
        label: 'Posición',
        value: '${book.posicion}',
      ));
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Información', style: theme.textTheme.titleMedium),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) => _buildInfoCard(context, item)).toList(),
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, _InfoItem item) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              Text(
                item.value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSection(BuildContext context) {
    final theme = Theme.of(context);

    // Parse the date range (format: "start → end" or just "start")
    final dateString = book.fechaTerminado!;
    late String startDateRaw;
    String? endDateRaw;
    late String startDateFormatted;
    String? endDateFormatted;

    if (dateString.contains('→')) {
      final parts = dateString.split('→').map((e) => e.trim()).toList();
      startDateRaw = parts[0];
      endDateRaw = parts.length > 1 ? parts[1] : null;
      startDateFormatted = _formatDate(startDateRaw);
      endDateFormatted = endDateRaw != null ? _formatDate(endDateRaw) : null;
    } else {
      startDateRaw = dateString;
      startDateFormatted = _formatDate(dateString);
    }

    final isOngoing = endDateFormatted == null && book.isReading;
    final isCompleted = book.isCompleted;

    // Calculate days between dates
    final daysBetween = _calculateDays(startDateRaw, endDateRaw);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Período de lectura', style: theme.textTheme.titleMedium),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Start date node
              Expanded(
                child: _buildDateNode(
                  context,
                  icon: Icons.play_arrow_rounded,
                  label: 'Inicio',
                  date: startDateFormatted,
                  color: AppColors.primary,
                  isActive: true,
                ),
              ),

              // Connecting line with progress and days
              Expanded(
                child: _buildConnectingLine(
                  context,
                  isCompleted: isCompleted,
                  isOngoing: isOngoing,
                  daysBetween: daysBetween,
                ),
              ),

              // End date node
              Expanded(
                child: _buildDateNode(
                  context,
                  icon: isCompleted
                      ? Icons.check_circle_rounded
                      : Icons.flag_rounded,
                  label: isOngoing ? 'En curso' : 'Fin',
                  date: endDateFormatted ?? (isOngoing ? '...' : '-'),
                  color: isCompleted
                      ? AppColors.statusCompleted
                      : (isOngoing
                          ? AppColors.statusReading
                          : theme.colorScheme.outline),
                  isActive: isCompleted || isOngoing,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateNode(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String date,
    required Color color,
    required bool isActive,
  }) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Icon circle
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isActive
                ? color.withValues(alpha: 0.15)
                : theme.colorScheme.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? color : theme.colorScheme.outline,
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            size: 22,
            color: isActive ? color : theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: 10),
        // Label
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.outline,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        // Date
        Text(
          date,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isActive ? color : theme.colorScheme.outline,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildConnectingLine(
    BuildContext context, {
    required bool isCompleted,
    required bool isOngoing,
    int? daysBetween,
  }) {
    final theme = Theme.of(context);
    final activeColor = isCompleted
        ? AppColors.statusCompleted
        : (isOngoing ? AppColors.statusReading : theme.colorScheme.outline);

    return Padding(
      padding: const EdgeInsets.only(bottom: 40), // Align with circles
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Days badge
          if (daysBetween != null && daysBetween > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: activeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: activeColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 14,
                    color: activeColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    daysBetween == 1 ? '1 día' : '$daysBetween días',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: activeColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          else if (isOngoing)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: activeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: activeColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_stories_rounded,
                    size: 14,
                    color: activeColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Leyendo',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: activeColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          // Line with progress
          Stack(
            alignment: Alignment.center,
            children: [
              // Background line
              Container(
                height: 3,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Progress line
              if (isCompleted || isOngoing)
                Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: isCompleted ? 1.0 : 0.5,
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: activeColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              // Animated dot for ongoing
              if (isOngoing)
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.statusReading,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.statusReading.withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'ene',
        'feb',
        'mar',
        'abr',
        'may',
        'jun',
        'jul',
        'ago',
        'sep',
        'oct',
        'nov',
        'dic'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  int? _calculateDays(String startDateStr, String? endDateStr) {
    try {
      final startDate = DateTime.parse(startDateStr);

      // If no end date, calculate days from start to today (for ongoing books)
      if (endDateStr == null) {
        if (book.isReading) {
          return DateTime.now().difference(startDate).inDays;
        }
        return null;
      }

      final endDate = DateTime.parse(endDateStr);
      return endDate.difference(startDate).inDays;
    } catch (e) {
      return null;
    }
  }

  Widget _buildTagsSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Etiquetas', style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: book.etiquetas.map((tag) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Text(
                tag,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryLight,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGenresSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Géneros', style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: book.generos.map((genre) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(genre, style: theme.textTheme.bodyMedium),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSummarySection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Resumen / Notas', style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            book.resumen!,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
          ),
        ),
      ],
    );
  }

  Widget _buildUrlSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Enlace', style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.link_rounded, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  book.url!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showOptionsMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_rounded),
              title: const Text('Editar libro'),
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.bookEditPath(book.id), extra: book);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_rounded, color: AppColors.error),
              title: const Text('Eliminar libro',
                  style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, ref);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    // Save the page context before showing the dialog
    final pageContext = context;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar libro'),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${book.nombre}"? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await ref
                  .read(deleteBookNotifierProvider.notifier)
                  .delete(book.id);
              if (success && pageContext.mounted) {
                // Navigate to the books list
                pageContext.go('/');
                ScaffoldMessenger.of(pageContext).showSnackBar(
                  const SnackBar(content: Text('Libro eliminado')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}
