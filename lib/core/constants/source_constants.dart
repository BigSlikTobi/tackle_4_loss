// lib/core/constants/source_constants.dart

// Mapping from Source table integer ID to display name
// **IMPORTANT:** Verify these IDs match your Supabase 'Source' table
const Map<int, String> sourceIdToDisplayName = {
  1: 'ESPN',
  2: 'NFL',
  3: 'FOX',
  4: 'BR', // Bleacher Report?
  // Add other sources if applicable
};

// Optional: Add a mapping for display name back to ID if needed for filtering (we don't need this for the News Feed anymore)
// const Map<String, int> sourceDisplayNameToId = {
//   'ESPN': 1,
//   'NFL': 2,
//   'FOX': 3,
//   'BR': 4,
// };

// We don't need the filter names/IDs anymore for the News Feed
// const String kAllSourcesFilterName = 'ALL';
// const int? kAllSourcesFilterId = null; // Use null to represent no filter
