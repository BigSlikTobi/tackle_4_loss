import 'package:flutter/foundation.dart';

@immutable
class TeamInfo {
  final String teamId; // e.g., "BUF"
  final String fullName; // e.g., "Buffalo Bills"
  final String division; // e.g., "AFC East"
  final String conference; // e.g., "AFC"

  const TeamInfo({
    required this.teamId,
    required this.fullName,
    required this.division,
    required this.conference,
  });

  factory TeamInfo.fromJson(Map<String, dynamic> json) {
    return TeamInfo(
      teamId: json['teamId'] as String? ?? '',
      fullName: json['fullName'] as String? ?? 'Unknown Team',
      division: json['division'] as String? ?? 'Unknown Division',
      conference: json['conference'] as String? ?? 'Unknown Conference',
    );
  }

  // Optional: Add toJson, equality operators if needed
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeamInfo &&
          runtimeType == other.runtimeType &&
          teamId == other.teamId;

  @override
  int get hashCode => teamId.hashCode;
}
