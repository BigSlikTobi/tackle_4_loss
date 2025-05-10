// File: lib/features/cluster_detail/ui/widgets/cluster_timeline_widget.dart
import 'dart:ui'; // Required for ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tackle_4_loss/features/cluster_detail/data/cluster_timeline_entry.dart';
import 'package:tackle_4_loss/features/cluster_detail/logic/cluster_detail_provider.dart';
import 'package:tackle_4_loss/core/theme/app_colors.dart';
import 'package:tackle_4_loss/core/providers/locale_provider.dart';
import 'package:intl/intl.dart';

class ClusterTimelineWidget extends ConsumerWidget {
  final List<ClusterTimelineEntry> entries;

  const ClusterTimelineWidget({super.key, required this.entries});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    final sortedEntries = List<ClusterTimelineEntry>.from(entries)
      ..sort((a, b) {
        final dateA = a.date;
        final dateB = b.date;
        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;
        return dateA.compareTo(dateB);
      });

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: Colors.grey.shade200.withAlpha(77), // 0.3 * 255 ≈ 77
          ),
          child: Row(
            children: _buildTimelineItems(context, ref, sortedEntries),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTimelineItems(
    BuildContext context,
    WidgetRef ref,
    List<ClusterTimelineEntry> sortedEntries,
  ) {
    final List<Widget> items = [];
    final selectedEntry = ref.watch(selectedTimelineEntryProvider);
    final theme = Theme.of(context);

    const double dotSize = 12.0;
    const double selectedDotSize = 16.0;
    final Color lineColor = Colors.grey.shade700;
    const double tapAreaPadding = 8.0;

    for (int i = 0; i < sortedEntries.length; i++) {
      final entry = sortedEntries[i];
      final bool isSelected = entry == selectedEntry;

      items.add(
        InkWell(
          onTap: () {
            ref.read(selectedTimelineEntryProvider.notifier).state = entry;
            _showTimelineEntryDialog(context, entry, ref);
            debugPrint(
              "Timeline dot tapped: Date ${entry.dateString}, Headline: ${entry.headline}",
            );
          },
          borderRadius: BorderRadius.circular(
            (selectedDotSize / 2) + tapAreaPadding,
          ),
          child: Padding(
            padding: const EdgeInsets.all(tapAreaPadding),
            child: Container(
              width: isSelected ? selectedDotSize : dotSize,
              height: isSelected ? selectedDotSize : dotSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primaryGreen : lineColor,
                border: Border.all(
                  color:
                      isSelected
                          ? theme.colorScheme.surface.withAlpha(
                            230,
                          ) // 0.9 * 255 ≈ 230
                          : Colors.transparent,
                  width: isSelected ? 2.5 : 0,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        isSelected
                            ? AppColors.primaryGreen.withAlpha(
                              179,
                            ) // 0.7 * 255 ≈ 179
                            : Colors.black.withAlpha(77), // 0.3 * 255 ≈ 77
                    blurRadius: isSelected ? 6.0 : 3.0,
                    spreadRadius: isSelected ? 2.0 : 1.0,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      if (i < sortedEntries.length - 1) {
        items.add(
          Expanded(
            child: Container(
              height: 2.5,
              color: lineColor,
              margin: const EdgeInsets.symmetric(horizontal: 1.0),
            ),
          ),
        );
      }
    }
    return items;
  }

  void _showTimelineEntryDialog(
    BuildContext context,
    ClusterTimelineEntry entry,
    WidgetRef ref,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      // alignment and insetPadding are properties of Dialog, not showDialog
      builder: (BuildContext dialogContext) {
        return Dialog(
          // --- MOVED DIALOG PROPERTIES HERE ---
          alignment: Alignment.topCenter,
          insetPadding: EdgeInsets.only(
            top:
                MediaQuery.of(context).padding.top +
                kToolbarHeight +
                20, // Adjust this value as needed
            left: 20.0,
            right: 20.0,
            bottom: 20.0,
          ),
          // --- END MOVED ---
          backgroundColor: Theme.of(
            dialogContext,
          ).cardColor.withAlpha(242), // 0.95 * 255 ≈ 242
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 8,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
              maxWidth: 500,
            ),
            child: TimelineEntryDialogContent(entry: entry),
          ),
        );
      },
    ).then((_) {
      // ref.read(selectedTimelineEntryProvider.notifier).state = null;
    });
  }
}

// Widget for Dialog Content (TimelineEntryDialogContent) remains the same as previous version
class TimelineEntryDialogContent extends ConsumerWidget {
  final ClusterTimelineEntry entry;

  const TimelineEntryDialogContent({super.key, required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentLocale = ref.watch(localeNotifierProvider);
    final DateFormat dateFormat = DateFormat.yMMMMd(currentLocale.languageCode);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  entry.headline,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  entry.date != null
                      ? dateFormat.format(entry.date!)
                      : 'Date Unknown',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                shrinkWrap: true,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 8.0,
                      top: 8.0,
                      bottom: 6.0,
                    ),
                    child: Text(
                      "Related Articles:",
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (entry.articles.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 8.0,
                      ),
                      child: Text(
                        "No articles for this event.",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: entry.articles.length,
                      itemBuilder: (context, index) {
                        final article = entry.articles[index];
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(6.0),
                            onTap: () {
                              debugPrint(
                                "Article '${article.headline}' in dialog tapped, but navigation is disabled.",
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Article details coming soon!"),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 8.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    article.headline,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    article.sourceName,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[700],
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder:
                          (context, index) => const Divider(
                            height: 0.5,
                            thickness: 0.5,
                            indent: 8,
                            endIndent: 8,
                          ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
