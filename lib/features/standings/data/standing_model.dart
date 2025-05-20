// lib/features/standings/data/standing_model.dart
import 'package:flutter/foundation.dart';

/// Model representing a team's standings information
class TeamStanding {
  final int id;
  final DateTime createdAt;
  final int teamId;
  final int season;
  final int wins;
  final int losses;
  final int ties;
  final int pointsFor;
  final int pointsAgainst;
  final int conferenceWins;
  final int conferenceLosses;
  final int conferenceTies;
  final int divisionWins;
  final int divisionLosses;
  final int divisionTies;
  final double winPercentage;
  final DateTime updatedAt;
  final String teamName;
  final String teamAbbreviation;
  final String conference;
  final String division;

  /// Returns the path to the team's logo asset
  String get logoPath {
    final formattedTeamName = teamName.toLowerCase().replaceAll(' ', '_');
    return 'assets/team_logos/$formattedTeamName.png';
  }

  /// Returns the path to the conference logo asset
  String get conferenceLogo => 'assets/team_logos/${conference.toLowerCase()}.png';

  const TeamStanding({
    required this.id,
    required this.createdAt,
    required this.teamId,
    required this.season,
    required this.wins,
    required this.losses,
    required this.ties,
    required this.pointsFor,
    required this.pointsAgainst,
    required this.conferenceWins,
    required this.conferenceLosses,
    required this.conferenceTies,
    required this.divisionWins,
    required this.divisionLosses,
    required this.divisionTies,
    required this.winPercentage,
    required this.updatedAt,
    required this.teamName,
    required this.teamAbbreviation,
    required this.conference,
    required this.division,
  });

  /// Factory constructor to create a TeamStanding from JSON
  factory TeamStanding.fromJson(Map<String, dynamic> json) {
    try {
      return TeamStanding(
        id: json['id'] as int,
        createdAt: DateTime.parse(json['created_at'] as String),
        teamId: json['team_id'] as int,
        season: json['season'] as int,
        wins: json['wins'] as int,
        losses: json['losses'] as int,
        ties: json['ties'] as int,
        pointsFor: json['points_for'] as int,
        pointsAgainst: json['points_against'] as int,
        conferenceWins: json['conference_wins'] as int,
        conferenceLosses: json['conference_losses'] as int,
        conferenceTies: json['conference_ties'] as int,
        divisionWins: json['division_wins'] as int,
        divisionLosses: json['division_losses'] as int,
        divisionTies: json['division_ties'] as int,
        winPercentage: (json['win_percentage'] as num).toDouble(),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        teamName: json['team_name'] as String,
        teamAbbreviation: json['team_abbreviation'] as String,
        conference: json['conference'] as String,
        division: json['division'] as String,
      );
    } catch (e, stack) {
      debugPrint('Error parsing TeamStanding from JSON: $e\n$stack');
      rethrow;
    }
  }

  @override
  String toString() {
    return 'TeamStanding(teamName: $teamName, record: $wins-$losses-$ties)';
  }
}

/// Response class for listing standings by season
class StandingsResponse {
  final List<TeamStanding> standings;
  final int season;

  StandingsResponse({required this.standings, required this.season});

  /// Group standings by division
  Map<String, List<TeamStanding>> byDivision() {
    final Map<String, List<TeamStanding>> result = {};
    
    for (final standing in standings) {
      final division = standing.division;
      if (!result.containsKey(division)) {
        result[division] = [];
      }
      result[division]!.add(standing);
    }
    
    // Sort each division by win percentage (descending)
    result.forEach((division, teams) {
      teams.sort((a, b) => b.winPercentage.compareTo(a.winPercentage));
    });
    
    return result;
  }

  /// Group standings by conference
  Map<String, List<TeamStanding>> byConference() {
    final Map<String, List<TeamStanding>> result = {};
    
    for (final standing in standings) {
      final conference = standing.conference;
      if (!result.containsKey(conference)) {
        result[conference] = [];
      }
      result[conference]!.add(standing);
    }
    
    // Sort each conference by win percentage (descending)
    result.forEach((conference, teams) {
      teams.sort((a, b) => b.winPercentage.compareTo(a.winPercentage));
    });
    
    return result;
  }

  /// Get all standings sorted by win percentage
  List<TeamStanding> overall() {
    final sortedStandings = List<TeamStanding>.from(standings);
    sortedStandings.sort((a, b) => b.winPercentage.compareTo(a.winPercentage));
    return sortedStandings;
  }
}
