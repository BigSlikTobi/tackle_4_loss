// Define the main categories
enum PositionGroup { offense, defense, special, other }

// Define the specific sort order within each category
const List<String> offensePositionOrder = [
  'QB',
  'WR',
  'RB',
  'FB',
  'TE',
  'OL',
  'C',
  'G',
  'T',
  'OT',
  'OG',
]; // Added C, G, T, OT, OG as sub-types of OL
const List<String> defensePositionOrder = [
  'LB',
  'ILB',
  'OLB',
  'DB',
  'CB',
  'S',
  'SAF',
  'DL',
  'DE',
  'DT',
  'NT',
]; // Added subtypes
const List<String> specialTeamsPositionOrder = [
  'K',
  'P',
  'LS',
  'H',
]; // Added Holder

// Helper function to categorize a position string
PositionGroup getPositionGroup(String? position) {
  if (position == null) return PositionGroup.other;
  final posUpper = position.toUpperCase();

  if (offensePositionOrder.contains(posUpper)) {
    return PositionGroup.offense;
  }
  if (defensePositionOrder.contains(posUpper)) {
    return PositionGroup.defense;
  }
  if (specialTeamsPositionOrder.contains(posUpper)) {
    return PositionGroup.special;
  }
  return PositionGroup.other; // Default category if not found
}

// Helper function to get the sort index for a position within its group
int getPositionSortIndex(String? position, PositionGroup group) {
  if (position == null) return 999;
  final posUpper = position.toUpperCase();

  switch (group) {
    case PositionGroup.offense:
      final index = offensePositionOrder.indexOf(posUpper);
      return index == -1 ? 999 : index; // Place unknown offense positions last
    case PositionGroup.defense:
      final index = defensePositionOrder.indexOf(posUpper);
      return index == -1 ? 999 : index; // Place unknown defense positions last
    case PositionGroup.special:
      final index = specialTeamsPositionOrder.indexOf(posUpper);
      return index == -1 ? 999 : index; // Place unknown special positions last
    case PositionGroup.other:
      return 999; // All 'other' are equal
  }
}
