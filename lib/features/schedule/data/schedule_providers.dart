import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'schedule_model.dart';
import 'schedule_service.dart';

/// Provider for the ScheduleService
final scheduleServiceProvider = Provider<ScheduleService>((ref) {
  final supabaseClient = Supabase.instance.client;
  return ScheduleService(supabaseClient);
});

/// Provider for tracking the currently selected week
final selectedWeekProvider = StateProvider<String>((ref) => '1'); // Default to week 1

/// Available weeks for schedule
final weekOptionsProvider = Provider<List<String>>((ref) {
  // Hall of Fame game, preseason games, and regular season weeks 1-18
  return [
    '0', // Hall of Fame game
    '0.1', '0.2', '0.3', // Preseason
    ...List.generate(18, (index) => '${index + 1}'), // Regular season weeks 1-18
  ];
});

/// Week label mapping provider
final weekLabelProvider = Provider<Map<String, String>>((ref) {
  return {
    '0': 'Hall of Fame Game',
    '0.1': 'Preseason Week 1',
    '0.2': 'Preseason Week 2',
    '0.3': 'Preseason Week 3',
    ...Map.fromIterables(
      List.generate(18, (index) => '${index + 1}'),
      List.generate(18, (index) => 'Week ${index + 1}'),
    ),
  };
});

/// Provider for fetching schedule data for the selected week
final scheduleProvider = FutureProvider<List<ScheduleGame>>((ref) async {
  final service = ref.watch(scheduleServiceProvider);
  final selectedWeek = ref.watch(selectedWeekProvider);
  
  return await service.getScheduleByWeek(selectedWeek);
});
