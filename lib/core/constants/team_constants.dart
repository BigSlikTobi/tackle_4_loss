final Map<String, String> teamLogoMap = {
  'ARI': 'arizona_cardinals',
  'ATL': 'atlanta_falcons',
  'BAL': 'baltimore_ravens',
  'BUF': 'buffalo_bills',
  'CAR': 'carolina_panthers',
  'CHI': 'chicago_bears',
  'CIN': 'cincinnati_bengals',
  'CLE': 'cleveland_browns',
  'DAL': 'dallas_cowboys',
  'DEN': 'denver_broncos',
  'DET': 'detroit_lions',
  'GB': 'green_bay_packers', // Use lowercase for consistency
  'HOU': 'houston_texans',
  'IND': 'indianapolis_colts',
  'JAC': 'jacksonville_jaguars', // Primary key for JAX/JAC
  // 'JAX': 'jacksonville_jaguars', // Removed duplicate
  'KC': 'kansas_city_chiefs',
  'LV': 'las_vegas_raiders',
  'LAC': 'los_angeles_chargers',
  'LAR': 'los_angeles_rams',
  'MIA': 'miami_dolphins',
  'MIN': 'minnesota_vikings',
  'NE': 'new_england_patriots',
  'NO': 'new_orleans_saints',
  'NYG': 'new_york_giants',
  'NYJ': 'new_york_jets',
  'PHI': 'philadelphia_eagles',
  'PIT': 'pittsburgh_steelers', // Corrected spelling
  'SF': 'san_francisco_49ers',
  'SEA': 'seattle_seahawks',
  'TB': 'tampa_bay_buccaneers',
  'TEN': 'tennessee_titans',
  'WAS': 'washington_commanders', // Primary key for WAS/WSH
  // 'WSH': 'washington_commanders', // Removed duplicate
};

// --- Map for Full Team Names ---
final Map<String, String> teamFullNameMap = {
  'ARI': 'Arizona Cardinals',
  'ATL': 'Atlanta Falcons',
  'BAL': 'Baltimore Ravens',
  'BUF': 'Buffalo Bills',
  'CAR': 'Carolina Panthers',
  'CHI': 'Chicago Bears',
  'CIN': 'Cincinnati Bengals',
  'CLE': 'Cleveland Browns',
  'DAL': 'Dallas Cowboys',
  'DEN': 'Denver Broncos',
  'DET': 'Detroit Lions',
  'GB': 'Green Bay Packers',
  'HOU': 'Houston Texans',
  'IND': 'Indianapolis Colts',
  'JAC': 'Jacksonville Jaguars',
  'KC': 'Kansas City Chiefs',
  'LV': 'Las Vegas Raiders',
  'LAC': 'Los Angeles Chargers',
  'LAR': 'Los Angeles Rams',
  'MIA': 'Miami Dolphins',
  'MIN': 'Minnesota Vikings',
  'NE': 'New England Patriots',
  'NO': 'New Orleans Saints',
  'NYG': 'New York Giants',
  'NYJ': 'New York Jets',
  'PHI': 'Philadelphia Eagles',
  'PIT': 'Pittsburgh Steelers',
  'SF': 'San Francisco 49ers',
  'SEA': 'Seattle Seahawks',
  'TB': 'Tampa Bay Buccaneers',
  'TEN': 'Tennessee Titans',
  'WAS': 'Washington Commanders',
};

// Helper function to get the full asset path
String getTeamLogoPath(String teamAbbreviation) {
  // Handle potential case issues and missing keys gracefully
  final logoStem = teamLogoMap[teamAbbreviation.toUpperCase()];
  if (logoStem != null) {
    // CORRECTED PATH: Returns 'assets/team_logos/some_team_name.png' instead of 'assets/logos/...'
    return 'assets/team_logos/${logoStem.toLowerCase().replaceAll(' ', '_')}.png';
  }
  // Return a placeholder path if team not found
  // Ensure you have an nfl.png in assets/team_logos/
  return 'assets/team_logos/nfl.png';
}

// Helper Function for Full Name
String getTeamFullName(String teamAbbreviation) {
  // Return the full name or the abbreviation if not found
  return teamFullNameMap[teamAbbreviation.toUpperCase()] ??
      teamAbbreviation.toUpperCase();
}
