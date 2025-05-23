// File: lib/features/cluster_detail/ui/cluster_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tackle_4_loss/core/widgets/global_app_bar.dart';
import 'package:tackle_4_loss/core/widgets/loading_indicator.dart';
import 'package:tackle_4_loss/core/widgets/error_message.dart';
import 'package:tackle_4_loss/features/cluster_detail/logic/cluster_detail_provider.dart';
import 'package:tackle_4_loss/features/cluster_detail/ui/widgets/cluster_timeline_widget.dart';
import 'package:tackle_4_loss/features/cluster_detail/ui/widgets/cluster_summary_widget.dart';
// --- Import new tabs widget ---
import 'package:tackle_4_loss/features/cluster_detail/ui/widgets/additional_views_tabs_widget.dart';
import 'package:tackle_4_loss/core/widgets/web_detail_wrapper.dart'; // Import WebDetailWrapper

class ClusterDetailScreen extends ConsumerWidget {
  final String clusterId;

  const ClusterDetailScreen({super.key, required this.clusterId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timelineAsyncValue = ref.watch(clusterTimelineProvider(clusterId));
    final summaryAsyncValue = ref.watch(clusterSummaryProvider(clusterId));

    return Scaffold(
      appBar: const GlobalAppBar(),
      body: WebDetailWrapper(
        // Wrap the body with WebDetailWrapper
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Cluster Summary Section
            Expanded(
              child: summaryAsyncValue.when(
                data: (summaryData) {
                  return ClusterSummaryWidget(summaryData: summaryData);
                },
                loading: () => const LoadingIndicator(),
                error:
                    (error, stack) => Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ErrorMessageWidget(
                        message:
                            "Failed to load story summary: ${error.toString()}",
                        onRetry:
                            () => ref.invalidate(
                              clusterSummaryProvider(clusterId),
                            ),
                      ),
                    ),
              ),
            ),

            // 2. Timeline Widget
            timelineAsyncValue.when(
              data: (timelineResponse) {
                if (timelineResponse.timelineData.isNotEmpty) {
                  return Column(
                    children: [
                      if (summaryAsyncValue is AsyncData ||
                          (summaryAsyncValue is AsyncLoading &&
                              timelineAsyncValue is AsyncData))
                        const SizedBox(height: 8.0),
                      const Divider(
                        height: 1,
                        indent: 0,
                        endIndent: 0,
                        thickness: 1,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: ClusterTimelineWidget(
                          entries: timelineResponse.timelineData,
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
              loading:
                  () => const SizedBox(
                    height: 60,
                    child: Center(
                      child: Text(
                        "Loading timeline...",
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ),
              error:
                  (error, stack) => Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16.0,
                    ),
                    alignment: Alignment.center,
                    height: 60,
                    color: Colors.red.withAlpha(13), // 0.05 * 255 ≈ 13
                    child: Text(
                      "Timeline error.",
                      style: TextStyle(color: Colors.red[700], fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
            ),

            // 3. Additional Views Tabs (Replaces "Tabs coming soon" placeholder)
            AdditionalViewsTabsWidget(clusterId: clusterId),
          ],
        ),
      ),
    );
  }
}
