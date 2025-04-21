import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart'; // For date formatting

@immutable
class PlayerInjury {
  final int id;
  final DateTime createdAt;
  final String? teamId; // e.g., "BUF"
  // final String? playerId; // Not needed for display based on example output
  final String? playerName;
  final String? playerImgUrl;
  final DateTime? date; // Date of the injury/update
  final String status; // Mapped status (e.g., "Questionable")
  final String description;

  const PlayerInjury({
    required this.id,
    required this.createdAt,
    this.teamId,
    this.playerName,
    this.playerImgUrl,
    this.date,
    required this.status,
    required this.description,
  });

  factory PlayerInjury.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse dates
    DateTime? parseDate(String? dateString) {
      if (dateString == null) return null;
      try {
        // Adjust format if needed, assuming YYYY-MM-DD first
        return DateFormat('yyyy-MM-dd').parseStrict(dateString);
      } catch (e) {
        debugPrint("Could not parse date '$dateString': $e");
        // Optionally try other formats or just return null
        return null;
      }
    }

    DateTime parseTimestamp(String? timestampString) {
      if (timestampString == null) return DateTime.now(); // Or throw error
      try {
        return DateTime.parse(timestampString); // Standard ISO format
      } catch (e) {
        debugPrint("Could not parse timestamp '$timestampString': $e");
        return DateTime.now(); // Fallback
      }
    }

    return PlayerInjury(
      id: json['id'] as int? ?? 0,
      createdAt: parseTimestamp(json['created_at'] as String?),
      teamId: json['teamId'] as String?,
      playerName: json['playerName'] as String?,
      playerImgUrl: json['playerImgUrl'] as String?,
      date: parseDate(json['date'] as String?),
      status: json['status'] as String? ?? 'Unknown',
      description: json['description'] as String? ?? '',
    );
  }

  // Optional formatting helper
  String get formattedDate {
    if (date == null) return '';
    try {
      return DateFormat.yMMMd().format(date!); // e.g., Jan 27, 2025
    } catch (e) {
      return '';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerInjury &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// Model for the overall response
class InjuryResponse {
  final List<PlayerInjury> injuries;
  final int? nextCursor; // ID of the last item

  InjuryResponse({required this.injuries, this.nextCursor});

  bool get hasMore => nextCursor != null;
}
