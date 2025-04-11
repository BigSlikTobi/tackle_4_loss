import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tackle_4_loss/core/providers/preference_provider.dart';
import 'package:tackle_4_loss/core/constants/team_constants.dart';

class TeamSelectionDropdown extends ConsumerWidget {
  const TeamSelectionDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the current selection state (can be null)
    final currentSelection = ref.watch(selectedTeamNotifierProvider);
    // Get the notifier to update the state
    final notifier = ref.read(selectedTeamNotifierProvider.notifier);

    // Prepare dropdown items from your team data
    final teamItems =
        teamLogoMap.entries.map((entry) {
          return DropdownMenuItem<String>(
            value:
                entry
                    .key, // Use the team abbreviation (e.g., 'DAL') as the value
            child: Row(
              // Display logo and name
              children: [
                Image.asset(
                  'assets/team_logos/${entry.value}.png', // Assuming logo path structure
                  height: 24,
                  width: 24,
                  errorBuilder:
                      (ctx, err, st) => const SizedBox(
                        width: 24,
                        height: 24,
                      ), // Handle missing logos
                ),
                const SizedBox(width: 8),
                Text(entry.key), // Show abbreviation or full name if available
              ],
            ),
          );
        }).toList();

    // Add an option for "All Teams" or "None"
    teamItems.insert(
      0,
      const DropdownMenuItem<String>(
        value: null, // Use null to represent no specific team selected
        child: Text('Select Your Team...'),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
      child: DropdownButton<String?>(
        value: currentSelection.valueOrNull, // Handle AsyncValue state
        isExpanded: true, // Make dropdown take full width
        hint: const Text('Select Team'), // Placeholder text
        items: teamItems,
        onChanged: (String? newTeamId) {
          // Call the notifier's method to update the team and save preference
          notifier.selectTeam(newTeamId);
        },
        // Basic styling
        underline: Container(height: 1, color: Colors.grey[400]),
        dropdownColor: Colors.white,
      ),
    );
  }
}
