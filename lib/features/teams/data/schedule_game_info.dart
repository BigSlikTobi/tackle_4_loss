import 'package:flutter/foundation.dart';

@immutable
class ScheduleGameInfo {
  final String gameId;
  // final int week; // Changed to String to accommodate "0.1" etc.
  final String week;
  final String date; // Expected format: YYYY-MM-DD
  final String time; // Expected format: HH:MM AM/PM TZ or similar
  final String stadium;
  final String homeTeamAbbreviation;
  final String awayTeamAbbreviation;
  final String? tvNetwork; // Optional

  const ScheduleGameInfo({
    required this.gameId,
    required this.week,
    required this.date,
    required this.time,
    required this.stadium,
    required this.homeTeamAbbreviation,
    required this.awayTeamAbbreviation,
    this.tvNetwork,
  });

  factory ScheduleGameInfo.fromJson(Map<String, dynamic> json) {
    // ---- DEBUG PRINTS START ----
    // ignore: avoid_print
    print('ScheduleGameInfo.fromJson received json: $json');
    // ---- DEBUG PRINTS END ----

    // Safely parse week, allowing for "0.1", "0.2" by keeping it as String
    final weekValue = json['week'];
    String parsedWeek;
    if (weekValue is String) {
      parsedWeek = weekValue;
    } else if (weekValue is num) {
      parsedWeek = weekValue.toString();
    } else {
      parsedWeek = '0'; // Default if type is unexpected
    }

    return ScheduleGameInfo(
      gameId: json['game_id'] as String? ?? json['id'] as String? ?? '', // Added fallback for 'id'
      week: parsedWeek,
      date: json['date'] as String? ?? '',
      time: json['time'] as String? ?? '',
      stadium: json['stadium'] as String? ?? 'N/A',
      homeTeamAbbreviation: json['home_team_name'] as String? ?? 'N/A', // Corrected parsing
      awayTeamAbbreviation: json['away_team_name'] as String? ?? 'N/A', // Corrected parsing
      tvNetwork: json['tv_network'] as String?,
    );
  }

  // Helper to determine if the game is a home game for a given team abbreviation
  bool isHomeGame(String currentTeamAbbreviation) {
    return homeTeamAbbreviation == currentTeamAbbreviation;
  }

  // Helper to get opponent's abbreviation
  String getOpponentAbbreviation(String currentTeamAbbreviation) {
    return isHomeGame(currentTeamAbbreviation) ? awayTeamAbbreviation : homeTeamAbbreviation;
  }
}
