import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tackle_4_loss/features/teams/data/player_injury.dart';
import 'package:tackle_4_loss/features/teams/data/injury_service.dart';

// 1. Provider for the InjuryService instance
final injuryServiceProvider = Provider<InjuryService>((ref) {
  return InjuryService();
});

// 2. State structure for the notifier
@immutable
class InjuryState {
  final List<PlayerInjury> injuries;
  final int? nextCursor; // Use cursor for pagination
  final bool hasMore;
  final bool isLoadingNextPage;

  const InjuryState({
    this.injuries = const [],
    this.nextCursor,
    this.hasMore = true,
    this.isLoadingNextPage = false,
  });

  InjuryState copyWith({
    List<PlayerInjury>? injuries,
    int? nextCursor, // Allow explicitly setting null
    bool? hasMore,
    bool? isLoadingNextPage,
    bool clearCursor = false, // Flag to handle null cursor from response
  }) {
    return InjuryState(
      injuries: injuries ?? this.injuries,
      nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
      hasMore: hasMore ?? this.hasMore,
      isLoadingNextPage: isLoadingNextPage ?? this.isLoadingNextPage,
    );
  }
}

// 3. AsyncNotifierProvider with family modifier (string team abbreviation)
final injuryProvider = AsyncNotifierProvider.family<
  InjuryNotifier,
  InjuryState,
  String // Family parameter: string team abbreviation
>(() => InjuryNotifier());

class InjuryNotifier extends FamilyAsyncNotifier<InjuryState, String> {
  String get teamAbbreviation => arg;

  @override
  Future<InjuryState> build(String arg) async {
    // Initial fetch (no cursor)
    return _fetchPage();
  }

  Future<InjuryState> _fetchPage({int? cursor}) async {
    final injuryService = ref.read(injuryServiceProvider);
    debugPrint(
      "[InjuryNotifier Team $teamAbbreviation] Fetching injuries ${cursor != null ? 'after ID $cursor' : 'initial'}",
    );

    try {
      final response = await injuryService.fetchInjuries(
        teamAbbreviation: teamAbbreviation,
        cursor: cursor,
      );
      debugPrint(
        "[InjuryNotifier Team $teamAbbreviation] Fetched injuries successfully. Count: ${response.injuries.length}, NextCursor: ${response.nextCursor}, HasMore: ${response.hasMore}",
      );
      return InjuryState(
        injuries: response.injuries,
        nextCursor: response.nextCursor,
        hasMore: response.hasMore,
      );
    } catch (e, s) {
      debugPrint(
        "[InjuryNotifier Team $teamAbbreviation] Error fetching injuries ${cursor != null ? 'after ID $cursor' : 'initial'}: $e",
      );
      throw Exception("Failed to load injuries: $e");
    }
  }

  Future<void> fetchNextPage() async {
    final currentState = state.valueOrNull;
    // Use nextCursor from state for the check
    if (currentState == null ||
        currentState.isLoadingNextPage ||
        !currentState.hasMore ||
        currentState.nextCursor == null) {
      debugPrint(
        "[InjuryNotifier Team $teamAbbreviation] Skipping fetchNextPage. Loading: ${currentState?.isLoadingNextPage}, HasMore: ${currentState?.hasMore}, Cursor: ${currentState?.nextCursor}",
      );
      return;
    }

    state = AsyncData(currentState.copyWith(isLoadingNextPage: true));
    final injuryService = ref.read(injuryServiceProvider);
    final currentCursor = currentState.nextCursor; // Use the stored cursor

    debugPrint(
      "[InjuryNotifier Team $teamAbbreviation] Attempting to fetch next page after cursor: $currentCursor",
    );

    try {
      final response = await injuryService.fetchInjuries(
        teamAbbreviation: teamAbbreviation,
        cursor: currentCursor, // Pass the cursor
      );

      debugPrint(
        "[InjuryNotifier Team $teamAbbreviation] Fetched next page successfully. New count: ${response.injuries.length}, NextCursor: ${response.nextCursor}, HasMore: ${response.hasMore}",
      );

      state = AsyncData(
        currentState.copyWith(
          injuries: [...currentState.injuries, ...response.injuries],
          nextCursor: response.nextCursor, // Update cursor
          hasMore: response.hasMore,
          isLoadingNextPage: false,
          clearCursor:
              response.nextCursor == null, // Clear if response cursor is null
        ),
      );
    } catch (e, s) {
      debugPrint(
        "[InjuryNotifier Team $teamAbbreviation] Error fetching next page after cursor $currentCursor: $e",
      );
      state = AsyncData(
        currentState.copyWith(
          hasMore: false, // Stop pagination on error
          isLoadingNextPage: false,
        ),
      );
    }
  }
}
