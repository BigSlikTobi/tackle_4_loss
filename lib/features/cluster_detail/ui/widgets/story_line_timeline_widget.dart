import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tackle_4_loss/core/providers/locale_provider.dart';
import 'package:tackle_4_loss/features/cluster_detail/data/story_line_timeline_entry.dart';
import 'package:tackle_4_loss/features/cluster_detail/logic/story_line_timeline_provider.dart';

class StoryLineTimelineWidget extends ConsumerStatefulWidget {
  final List<StoryLineTimelineEntry> entries;
  final String clusterId;

  const StoryLineTimelineWidget({
    super.key,
    required this.entries,
    required this.clusterId,
  });

  @override
  ConsumerState<StoryLineTimelineWidget> createState() =>
      _StoryLineTimelineWidgetState();
}

class _StoryLineTimelineWidgetState
    extends ConsumerState<StoryLineTimelineWidget> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // DEBUG: Log all entry IDs and cluster IDs to validate deduplication
    for (final entry in widget.entries) {
      debugPrint(
        '[TimelineWidget] Entry: id=${entry.id}, clusterId=${entry.clusterId}, headline=${entry.headline}',
      );
    }

    if (widget.entries.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final selectedEntry = ref.watch(selectedStoryLineTimelineEntryProvider);
    final int totalEntries = widget.entries.length;
    const double dotWidth = 12.0;
    const double dotHeight = 12.0;
    const double minSpacing = 5.0;
    const double horizontalPadding = 16.0; // left+right padding for timeline

    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth =
            constraints.maxWidth - horizontalPadding * 2;
        final double totalDotWidth = dotWidth * totalEntries;
        final int gaps = totalEntries > 1 ? totalEntries - 1 : 1;
        double spacing = (availableWidth - totalDotWidth) / gaps;

        bool isScrollable = spacing < minSpacing;
        double usedSpacing = isScrollable ? minSpacing : spacing;
        double timelineWidth =
            isScrollable
                ? (totalDotWidth + usedSpacing * gaps + horizontalPadding * 2)
                : constraints.maxWidth;

        Widget timelineDots;
        if (!isScrollable) {
          // Evenly distribute dots with calculated spacing
          timelineDots = Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (int i = 0; i < totalEntries; i++) ...[
                if (i > 0) SizedBox(width: usedSpacing),
                SizedBox(
                  width: dotWidth,
                  height: dotHeight,
                  child: Center(
                    child: _TimelineDot(
                      dotWidth: dotWidth,
                      dotHeight: dotHeight,
                      entry: widget.entries[i],
                      isSelected: selectedEntry?.id == widget.entries[i].id,
                      onTap: () => _handleDotTap(widget.entries[i]),
                    ),
                  ),
                ),
              ],
            ],
          );
        } else {
          // Scrollable timeline with minimum spacing
          timelineDots = SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _scrollController,
            child: SizedBox(
              width: timelineWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  for (int i = 0; i < totalEntries; i++) ...[
                    if (i > 0) SizedBox(width: usedSpacing),
                    SizedBox(
                      width: dotWidth,
                      height: dotHeight,
                      child: Center(
                        child: _TimelineDot(
                          dotWidth: dotWidth,
                          dotHeight: dotHeight,
                          entry: widget.entries[i],
                          isSelected: selectedEntry?.id == widget.entries[i].id,
                          onTap: () => _handleDotTap(widget.entries[i]),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        return Container(
          height: 40,
          width: double.infinity,
          color: theme.canvasColor,
          child: Stack(
            children: [
              // Connecting line through the middle of dots
              Positioned(
                top: 20,
                left: 8,
                right: 8,
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
              // Dots (either evenly distributed or scrollable)
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: horizontalPadding,
                  ),
                  child: timelineDots,
                ),
              ),
              if (isScrollable)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    child: Container(
                      width: 24,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.transparent,
                            theme.canvasColor.withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _handleDotTap(StoryLineTimelineEntry entry) {
    // Update selected entry
    ref.read(selectedStoryLineTimelineEntryProvider.notifier).state = entry;

    // Show context menu
    _showTimelineContextMenu(entry);
  }

  void _showTimelineContextMenu(StoryLineTimelineEntry entry) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          alignment: Alignment.topCenter,
          insetPadding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + kToolbarHeight + 16,
            left: 16.0,
            right: 16.0,
            bottom: 16.0,
          ),
          backgroundColor: Theme.of(dialogContext).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 8,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
              maxWidth: 500,
            ),
            child: _TimelineContextMenuContent(entry: entry),
          ),
        );
      },
    ).then((_) {
      // Optional: Clear selection when dialog closes
      // ref.read(selectedStoryLineTimelineEntryProvider.notifier).state = null;
    });
  }
}

class _TimelineDot extends StatelessWidget {
  final StoryLineTimelineEntry entry;
  final bool isSelected;
  final VoidCallback onTap;
  final double dotWidth;
  final double dotHeight;

  const _TimelineDot({
    required this.entry,
    required this.isSelected,
    required this.onTap,
    required this.dotWidth,
    required this.dotHeight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double selectedDotWidth = dotWidth * 0.8;
    final double selectedDotHeight = dotHeight * 1.2;
    const double tapAreaPadding = 4.0;

    final Color dotColor =
        isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface.withOpacity(0.7);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Padding(
        padding: const EdgeInsets.all(tapAreaPadding),
        child: Container(
          width: isSelected ? selectedDotWidth : dotWidth,
          height: isSelected ? selectedDotHeight : dotHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40.0),
            color: dotColor,
            border: Border.all(
              color:
                  isSelected
                      ? theme.colorScheme.onPrimary.withOpacity(0.9)
                      : Colors.transparent,
              width: isSelected ? 1.0 : 0,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    isSelected
                        ? theme.colorScheme.primary.withOpacity(0.5)
                        : Colors.black.withOpacity(0.15),
                blurRadius: isSelected ? 10.0 : 4.0,
                spreadRadius: isSelected ? 3.0 : 1.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimelineContextMenuContent extends ConsumerWidget {
  final StoryLineTimelineEntry entry;

  const _TimelineContextMenuContent({required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentLocale = ref.watch(localeNotifierProvider);
    final DateFormat dateFormat = DateFormat.yMMMMd(currentLocale.languageCode);

    // Use padding and minimal height, and new structure: headline, content, date/source row
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Headline
          if (entry.headline.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                _stripHtml(entry.headline),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          // Content
          if (entry.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                _stripHtml(entry.content),
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
            ),
          // Date and Source row
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 14.0,
                color: theme.textTheme.bodySmall?.color,
              ),
              const SizedBox(width: 4.0),
              Text(
                entry.createdAt != null
                    ? dateFormat.format(entry.createdAt!)
                    : 'Date Unknown',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              Icon(
                Icons.source,
                size: 14,
                color: theme.textTheme.bodySmall?.color,
              ),
              const SizedBox(width: 4.0),
              Text(
                entry.source.isNotEmpty ? entry.source : 'Unknown',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          // Close button
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _stripHtml(String htmlText) {
    final RegExp htmlTagsRegex = RegExp(
      r'<[^>]*>',
      multiLine: true,
      caseSensitive: true,
    );
    return htmlText.replaceAll(htmlTagsRegex, '').trim();
  }
}
