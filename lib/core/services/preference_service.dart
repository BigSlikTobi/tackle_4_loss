import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {
  static const String _selectedTeamKey = 'selectedTeamId';

  Future<void> saveSelectedTeam(String? teamId) async {
    final prefs = await SharedPreferences.getInstance();
    if (teamId == null) {
      await prefs.remove(_selectedTeamKey);
    } else {
      await prefs.setString(_selectedTeamKey, teamId);
    }
  }

  Future<String?> getSelectedTeam() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedTeamKey);
  }
}
