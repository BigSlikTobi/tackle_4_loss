// lib/features/standings/logic/standings_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tackle_4_loss/features/standings/data/standing_model.dart';
import 'package:tackle_4_loss/features/standings/data/standings_service.dart';

// Provider for the StandingsService
final standingsServiceProvider = Provider<StandingsService>((ref) {
  return StandingsService();
});

// FutureProvider to fetch current season standings (2024)
final standingsProvider = FutureProvider<StandingsResponse>((ref) async {
  final service = ref.watch(standingsServiceProvider);
  // Always fetch 2024 season as it's the current season
  return service.fetchStandingsBySeason(2024);
});

// Provider for the selected standings view type (NFL, Conference, Division)
enum StandingsViewType {
  nfl,
  conference,
  division,
}

final standingsViewTypeProvider = StateProvider<StandingsViewType>((ref) {
  return StandingsViewType.nfl;
});
