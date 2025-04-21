import 'package:flutter/foundation.dart';

@immutable
class PlayerInfo {
  final String? teamId;
  final String? name;
  final int? number;
  final String? headshotURL;
  final String? position;
  final int? age;
  final String height;
  final String weight;
  final String? college;
  final int? yearsExp; // Keep type as int?

  const PlayerInfo({
    this.teamId,
    this.name,
    this.number,
    this.headshotURL,
    this.position,
    this.age,
    required this.height,
    required this.weight,
    this.college,
    this.yearsExp,
  });

  factory PlayerInfo.fromJson(Map<String, dynamic> json) {
    // --- FIX: Robust parsing for yearsExp ---
    int? parsedYearsExp;
    final dynamic yearsExpValue =
        json['years_exp']; // Get the value dynamically
    if (yearsExpValue != null) {
      if (yearsExpValue is int) {
        parsedYearsExp = yearsExpValue; // Assign directly if already int
      } else if (yearsExpValue is String) {
        // Attempt to parse if it's a string
        parsedYearsExp = int.tryParse(yearsExpValue);
      }
      // If it's neither int nor String, parsedYearsExp remains null
    }
    // --- End Fix ---

    return PlayerInfo(
      teamId: json['teamId'] as String?,
      name: json['name'] as String?,
      number: json['number'] as int?,
      headshotURL: json['headshotURL'] as String?,
      position: json['position'] as String?,
      age: json['age'] as int?,
      height: json['height'] as String? ?? '',
      weight: json['weight'] as String? ?? '',
      college: json['college'] as String?,
      yearsExp: parsedYearsExp, // Assign the parsed value
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerInfo &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          number == other.number &&
          teamId == other.teamId;

  @override
  int get hashCode => name.hashCode ^ number.hashCode ^ teamId.hashCode;
}

// Model for the overall response including pagination (remains same)
class RosterResponse {
  final List<PlayerInfo> players;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  RosterResponse({
    required this.players,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  bool get hasMorePages => page < totalPages;
}
