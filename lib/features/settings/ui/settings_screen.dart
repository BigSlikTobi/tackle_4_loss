import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tackle_4_loss/core/widgets/global_app_bar.dart';
import 'package:tackle_4_loss/core/providers/locale_provider.dart';
import 'package:tackle_4_loss/core/providers/preference_provider.dart';
import 'package:tackle_4_loss/core/constants/team_constants.dart';
import 'package:tackle_4_loss/core/widgets/loading_indicator.dart';
import 'package:tackle_4_loss/core/widgets/error_message.dart';
import 'package:tackle_4_loss/core/constants/layout_constants.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  // --- Helper to build team selection grid ---
  Widget _buildTeamSelectionGrid(
    BuildContext context,
    WidgetRef ref,
    String? currentlySelectedTeamId,
  ) {
    final theme = Theme.of(context);
    final notifier = ref.read(selectedTeamNotifierProvider.notifier);

    // Get team entries and sort them alphabetically by abbreviation (key)
    final sortedTeams =
        teamLogoMap.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Wrap(
        alignment: WrapAlignment.center, // Center items within the Wrap
        spacing: 12.0, // Horizontal space between logos
        runSpacing: 12.0, // Vertical space between rows of logos
        children:
            sortedTeams.map((entry) {
              final teamId = entry.key;
              final isCurrentlySelected = teamId == currentlySelectedTeamId;

              return InkWell(
                onTap: () {
                  // Prevent action if already selected
                  if (isCurrentlySelected) return;

                  // Show confirmation dialog only if changing FROM an existing selection
                  if (currentlySelectedTeamId != null) {
                    _showConfirmationDialog(context, ref, teamId);
                  } else {
                    // Directly select if no team was previously chosen
                    notifier.selectTeam(teamId);
                    debugPrint("Selected initial favorite team: $teamId");
                    // Provide user feedback
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Favorite team set to ${getTeamFullName(teamId)}',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(8.0), // Match border radius
                child: Container(
                  padding: const EdgeInsets.all(
                    6.0,
                  ), // Padding inside the border
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color:
                          isCurrentlySelected
                              ? theme
                                  .colorScheme
                                  .primary // Highlight color
                              : Colors.grey.shade300, // Default border
                      width:
                          isCurrentlySelected
                              ? 2.0
                              : 1.0, // Thicker border if selected
                    ),
                    // Add a subtle shadow when selected for depth
                    boxShadow:
                        isCurrentlySelected
                            ? [
                              BoxShadow(
                                color: Colors.black.withAlpha(
                                  // Use withAlpha for opacity
                                  (255 * 0.1).round(),
                                ),
                                blurRadius: 4,
                                offset: const Offset(
                                  0,
                                  1,
                                ), // Slight vertical offset
                              ),
                            ]
                            : [], // No shadow if not selected
                  ),
                  // Display team logo
                  child: Image.asset(
                    getTeamLogoPath(teamId),
                    height: 30, // Slightly larger logo
                    width: 30,
                    fit: BoxFit.contain,
                    // Fallback for missing logo image
                    errorBuilder:
                        (ctx, err, st) => const SizedBox(width: 30, height: 30),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  // --- Helper to show confirmation dialog ---
  void _showConfirmationDialog(
    BuildContext context,
    WidgetRef ref,
    String newTeamId, // The team the user tapped on
  ) {
    final notifier = ref.read(selectedTeamNotifierProvider.notifier);
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0), // Softer corners
          ),
          title: const Text('Change Favorite Team?'),
          content: Row(
            mainAxisAlignment:
                MainAxisAlignment.center, // Center content horizontally
            mainAxisSize:
                MainAxisSize.min, // Prevent row from expanding unnecessarily
            children: [
              const Text('Switch to '),
              const SizedBox(width: 8),
              // Show the logo of the team being switched TO
              Image.asset(
                getTeamLogoPath(newTeamId),
                height: 30,
                width: 30,
                errorBuilder:
                    (ctx, err, st) => Text(newTeamId), // Fallback text
              ),
              const SizedBox(width: 4),
              // Use Flexible to prevent overflow if team name is long
              Flexible(
                child: Text(
                  '${getTeamFullName(newTeamId)}?',
                  textAlign: TextAlign.start, // Default alignment
                ),
              ),
            ],
          ),
          actions: <Widget>[
            // Cancel button
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(dialogContext); // Close the dialog
              },
            ),
            // Confirm button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary, // Use theme color
                foregroundColor: theme.colorScheme.onPrimary, // Text color
              ),
              child: const Text('Confirm'),
              onPressed: () {
                // Update the selected team using the notifier
                notifier.selectTeam(newTeamId);
                debugPrint("Changed favorite team to: $newTeamId");
                Navigator.pop(dialogContext); // Close the dialog
                // Provide user feedback
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Favorite team changed to ${getTeamFullName(newTeamId)}',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final currentLocale = ref.watch(localeNotifierProvider);
    final localeNotifier = ref.read(localeNotifierProvider.notifier);
    final teamState = ref.watch(selectedTeamNotifierProvider);

    return Scaffold(
      // --- FIX: Remove the title argument to default to app logo ---
      appBar: const GlobalAppBar(automaticallyImplyLeading: true),
      // --- End Fix ---
      body: Center(
        // Center and constrain the body content
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
          child: ListView(
            // The main content list
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            children: [
              // --- Favorite Team Setting Section ---
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
                child: Text(
                  'Favorite Team',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),

              // --- Conditional Team Selection UI ---
              teamState.when(
                loading:
                    () => const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: LoadingIndicator(),
                    ),
                error:
                    (err, stack) => Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ErrorMessageWidget(
                        message: 'Could not load team preference: $err',
                      ),
                    ),
                data: (selectedTeamId) {
                  // --- Display based on whether a team is selected ---
                  if (selectedTeamId == null) {
                    // State: No Team Selected
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 4.0),
                          child: Text(
                            'Select your favorite team:', // Instruction text
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        // Show the grid for selection
                        _buildTeamSelectionGrid(context, ref, null),
                      ],
                    );
                  } else {
                    // State: A Team IS Selected
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display current selection
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            16.0,
                            12.0,
                            16.0,
                            4.0,
                          ),
                          child: Text(
                            'Your Team:',
                            style: textTheme.titleMedium,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Image.asset(
                                getTeamLogoPath(selectedTeamId),
                                height: 36,
                                width: 36,
                                errorBuilder:
                                    (ctx, err, st) =>
                                        const SizedBox(width: 36, height: 36),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                getTeamFullName(selectedTeamId),
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Option to change selection
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            16.0,
                            0.0,
                            16.0,
                            4.0,
                          ),
                          child: Text(
                            'Change your Team:',
                            style: textTheme.titleMedium,
                          ),
                        ),
                        // Show grid again, highlighting current selection
                        _buildTeamSelectionGrid(context, ref, selectedTeamId),
                      ],
                    );
                  }
                },
              ),

              // --- End Team Selection ---
              const Divider(height: 32.0, indent: 16.0, endIndent: 16.0),

              // --- Language Setting Section ---
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Text(
                  'Language / Sprache',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              // Language Radio Buttons
              RadioListTile<Locale>(
                title: const Text('English'),
                value: const Locale('en'),
                groupValue: currentLocale,
                onChanged: (Locale? value) {
                  if (value != null) localeNotifier.setLocale(value);
                },
                selected: currentLocale.languageCode == 'en',
                activeColor: theme.colorScheme.primary,
                selectedTileColor: theme.colorScheme.primary.withAlpha(
                  15,
                ), // Subtle highlight
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              ),
              RadioListTile<Locale>(
                title: const Text('Deutsch'),
                value: const Locale('de'),
                groupValue: currentLocale,
                onChanged: (Locale? value) {
                  if (value != null) localeNotifier.setLocale(value);
                },
                selected: currentLocale.languageCode == 'de',
                activeColor: theme.colorScheme.primary,
                selectedTileColor: theme.colorScheme.primary.withAlpha(
                  15,
                ), // Subtle highlight
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              ),

              // --- End Language Setting ---
              const Divider(height: 32.0, indent: 16.0, endIndent: 16.0),

              // --- Add more settings below if needed ---
            ],
          ),
        ),
      ),
    );
  }
}
