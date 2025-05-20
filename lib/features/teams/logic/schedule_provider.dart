import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tackle_4_loss/features/teams/data/schedule_game_info.dart';
import 'package:tackle_4_loss/features/teams/data/schedule_service.dart';

// 1. Provider for the ScheduleService instance
final scheduleServiceProvider = Provider<ScheduleService>((ref) {
  return ScheduleService();
});

// 2. FutureProvider.family to fetch the schedule for a given team abbreviation
final teamScheduleProvider = FutureProvider.family<
    List<ScheduleGameInfo>, String>((ref, teamAbbreviation) async {
  final scheduleService = ref.watch(scheduleServiceProvider);
  return scheduleService.fetchScheduleByTeamAbbreviation(teamAbbreviation);
});
