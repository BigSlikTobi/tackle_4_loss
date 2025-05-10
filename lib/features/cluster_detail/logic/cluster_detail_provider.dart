// File: lib/features/cluster_detail/logic/cluster_detail_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tackle_4_loss/features/cluster_detail/data/cluster_detail_service.dart';
import 'package:tackle_4_loss/features/cluster_detail/data/cluster_timeline_response.dart';
import 'package:tackle_4_loss/features/cluster_detail/data/cluster_timeline_entry.dart';
import 'package:tackle_4_loss/features/cluster_detail/data/cluster_summary_data.dart';
// --- Import new models ---
import 'package:tackle_4_loss/features/cluster_detail/data/single_view_data.dart';

// Enum for different additional view types
enum AdditionalViewType {
  coach,
  player,
  franchise,
  team,
  dynamic1,
  dynamic2,
  none,
}

// Provider for the ClusterDetailService
final clusterDetailServiceProvider = Provider<ClusterDetailService>((ref) {
  return ClusterDetailService();
});

// --- Existing Providers ---
final clusterTimelineProvider =
    FutureProvider.family<ClusterTimelineResponse, String>((
      ref,
      clusterId,
    ) async {
      final service = ref.watch(clusterDetailServiceProvider);
      return service.getClusterTimeline(clusterId);
    });

final selectedTimelineEntryProvider = StateProvider<ClusterTimelineEntry?>(
  (ref) => null,
);

final clusterSummaryProvider =
    FutureProvider.family<ClusterSummaryData, String>((ref, clusterId) async {
      final service = ref.watch(clusterDetailServiceProvider);
      return service.getClusterSummary(clusterId);
    });

// --- Providers for Additional Views ---
final coachViewProvider = FutureProvider.family<SingleViewData, String>((
  ref,
  clusterId,
) async {
  final service = ref.watch(clusterDetailServiceProvider);
  return service.getCoachView(clusterId);
});

final playerViewProvider = FutureProvider.family<SingleViewData, String>((
  ref,
  clusterId,
) async {
  final service = ref.watch(clusterDetailServiceProvider);
  return service.getPlayerView(clusterId);
});

final franchiseViewProvider = FutureProvider.family<SingleViewData, String>((
  ref,
  clusterId,
) async {
  final service = ref.watch(clusterDetailServiceProvider);
  return service.getFranchiseView(clusterId);
});

final teamViewProvider = FutureProvider.family<SingleViewData, String>((
  ref,
  clusterId,
) async {
  final service = ref.watch(clusterDetailServiceProvider);
  return service.getTeamView(clusterId);
});

final dynamicViewsProvider =
    FutureProvider.family<DynamicViewsResponse, String>((ref, clusterId) async {
      final service = ref.watch(clusterDetailServiceProvider);
      return service.getDynamicViews(clusterId);
    });

// Provider to keep track of the currently selected additional view tab
final selectedAdditionalViewProvider = StateProvider<AdditionalViewType>(
  (ref) => AdditionalViewType.none,
);

// Provider to get the data for the currently selected additional view (memoized)
final currentViewDataProvider =
    Provider.family<AsyncValue<SingleViewData?>, String>((ref, clusterId) {
      final selectedViewType = ref.watch(selectedAdditionalViewProvider);

      switch (selectedViewType) {
        case AdditionalViewType.coach:
          return ref.watch(coachViewProvider(clusterId));
        case AdditionalViewType.player:
          return ref.watch(playerViewProvider(clusterId));
        case AdditionalViewType.franchise:
          return ref.watch(franchiseViewProvider(clusterId));
        case AdditionalViewType.team:
          return ref.watch(teamViewProvider(clusterId));
        case AdditionalViewType.dynamic1:
          final dynamicViewsAsync = ref.watch(dynamicViewsProvider(clusterId));
          return dynamicViewsAsync.whenData(
            (data) => data.views.isNotEmpty ? data.views[0] : null,
          );
        case AdditionalViewType.dynamic2:
          final dynamicViewsAsync = ref.watch(dynamicViewsProvider(clusterId));
          return dynamicViewsAsync.whenData(
            (data) => data.views.length > 1 ? data.views[1] : null,
          );
        case AdditionalViewType.none:
          return const AsyncData(null);
      }
    });
