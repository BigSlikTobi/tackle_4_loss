
/// Model representing a scheduled NFL game
class ScheduleGame {
  final String week;
  final String homeTeamName; // This is the abbreviation
  final int homeTeamId;
  final String awayTeamName; // This is the abbreviation
  final int awayTeamId;
  final DateTime date;
  final String? time;
  final String stadium;

  ScheduleGame({
    required this.week,
    required this.homeTeamName,
    required this.homeTeamId,
    required this.awayTeamName,
    required this.awayTeamId,
    required this.date,
    this.time,
    required this.stadium,
  });

  factory ScheduleGame.fromJson(Map<String, dynamic> json) {
    return ScheduleGame(
      week: json['week'] as String,
      homeTeamName: json['home_team_name'] as String, // Already abbreviation
      homeTeamId: json['home_team_id'] as int,
      awayTeamName: json['away_team_name'] as String, // Already abbreviation
      awayTeamId: json['away_team_id'] as int,
      date: DateTime.parse(json['date'] as String),
      time: json['time'] as String?,
      stadium: json['stadium'] as String,
    );
  }

  @override
  String toString() {
    return 'ScheduleGame{week: $week, homeTeamName: $homeTeamName, awayTeamName: $awayTeamName, date: $date}'; // Reverted
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is ScheduleGame &&
        other.week == week &&
        other.homeTeamName == homeTeamName &&
        other.homeTeamId == homeTeamId &&
        other.awayTeamName == awayTeamName &&
        other.awayTeamId == awayTeamId &&
        other.date == date &&
        other.time == time &&
        other.stadium == stadium;
  }

  @override
  int get hashCode {
    return Object.hash(
      week,
      homeTeamName,
      homeTeamId,
      awayTeamName,
      awayTeamId,
      date,
      time,
      stadium,
    );
  }
}

/// Helper extension to group games by week
extension ScheduleGameListExtensions on List<ScheduleGame> {
  Map<String, List<ScheduleGame>> groupByWeek() {
    final Map<String, List<ScheduleGame>> result = {};
    
    for (final game in this) {
      if (!result.containsKey(game.week)) {
        result[game.week] = [];
      }
      result[game.week]!.add(game);
    }
    
    return result;
  }
}
