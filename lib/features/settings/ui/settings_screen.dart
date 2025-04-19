import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tackle_4_loss/core/widgets/global_app_bar.dart';
import 'package:tackle_4_loss/core/providers/locale_provider.dart';
import 'package:tackle_4_loss/core/providers/preference_provider.dart';
import 'package:tackle_4_loss/core/constants/team_constants.dart';
import 'package:tackle_4_loss/core/widgets/loading_indicator.dart';
import 'package:tackle_4_loss/core/widgets/error_message.dart';

const double kMaxContentWidth = 1200.0;

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  // Helper: _buildTeamSelectionGrid remains the same
  Widget _buildTeamSelectionGrid(
    BuildContext context,
    WidgetRef ref,
    String? currentlySelectedTeamId,
  ) {
    final theme = Theme.of(context);
    final notifier = ref.read(selectedTeamNotifierProvider.notifier);

    final sortedTeams =
        teamLogoMap.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 12.0,
        runSpacing: 12.0,
        children:
            sortedTeams.map((entry) {
              final teamId = entry.key;
              final isCurrentlySelected = teamId == currentlySelectedTeamId;

              return InkWell(
                onTap: () {
                  if (isCurrentlySelected) return;
                  if (currentlySelectedTeamId == null) {
                    notifier.selectTeam(teamId);
                    debugPrint("Selected initial favorite team: $teamId");
                  } else {
                    _showConfirmationDialog(context, ref, teamId);
                  }
                },
                borderRadius: BorderRadius.circular(8.0),
                child: Container(
                  padding: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color:
                          isCurrentlySelected
                              ? theme.colorScheme.primary
                              : Colors.grey.shade300,
                      width: isCurrentlySelected ? 2.0 : 1.0,
                    ),
                    boxShadow:
                        isCurrentlySelected
                            ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ]
                            : [],
                  ),
                  child: Image.asset(
                    getTeamLogoPath(teamId),
                    height: 24,
                    width: 24,
                    fit: BoxFit.contain,
                    errorBuilder:
                        (ctx, err, st) => const SizedBox(width: 24, height: 24),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  // Helper: _showConfirmationDialog modified
  void _showConfirmationDialog(
    BuildContext context,
    WidgetRef ref,
    String newTeamId,
  ) {
    final notifier = ref.read(selectedTeamNotifierProvider.notifier);
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: const Text('Change Favorite Team?'),
          // --- Modified Content ---
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize:
                MainAxisSize.min, // Allow Row to shrink if content is short
            children: [
              const Text('Switch to '),
              const SizedBox(width: 8),
              Image.asset(
                getTeamLogoPath(newTeamId),
                height: 30,
                width: 30,
                errorBuilder: (ctx, err, st) => Text(newTeamId),
              ),
              const SizedBox(width: 4),
              // Wrap the potentially long text with Flexible
              Flexible(
                child: Text(
                  getTeamFullName(newTeamId) + '?',
                  // softWrap: true, // Already true by default for Text
                  textAlign: TextAlign.start, // Adjust alignment if needed
                ),
              ),
            ],
          ),
          // --- End Modified Content ---
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(dialogContext);
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              child: const Text('Confirm'),
              onPressed: () {
                notifier.selectTeam(newTeamId);
                debugPrint("Changed favorite team to: $newTeamId");
                Navigator.pop(dialogContext);
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
      appBar: const GlobalAppBar(title: Text('Settings')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            children: [
              // --- Favorite Team Setting ---
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
                  if (selectedTeamId == null) {
                    // State 2: No Team Selected
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 4.0),
                          child: Text(
                            'Select your favorite team here:',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        _buildTeamSelectionGrid(context, ref, null),
                      ],
                    );
                  } else {
                    // State 1: Team Selected
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            16.0,
                            0.0,
                            16.0,
                            4.0,
                          ),
                          child: Text(
                            'Change your Team here:',
                            style: textTheme.titleMedium,
                          ),
                        ),
                        _buildTeamSelectionGrid(context, ref, selectedTeamId),
                      ],
                    );
                  }
                },
              ),

              // --- End Conditional Team Selection UI ---
              const Divider(height: 32.0, indent: 16.0, endIndent: 16.0),

              // --- Language Setting ---
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
              RadioListTile<Locale>(
                title: const Text('English'),
                value: const Locale('en'),
                groupValue: currentLocale,
                onChanged: (Locale? value) {
                  if (value != null) {
                    localeNotifier.setLocale(value);
                  }
                },
                selected: currentLocale.languageCode == 'en',
                activeColor: theme.colorScheme.primary,
                selectedTileColor: theme.colorScheme.primary.withOpacity(0.05),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              ),
              RadioListTile<Locale>(
                title: const Text('Deutsch'),
                value: const Locale('de'),
                groupValue: currentLocale,
                onChanged: (Locale? value) {
                  if (value != null) {
                    localeNotifier.setLocale(value);
                  }
                },
                selected: currentLocale.languageCode == 'de',
                activeColor: theme.colorScheme.primary,
                selectedTileColor: theme.colorScheme.primary.withOpacity(0.05),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              ),

              const Divider(height: 32.0, indent: 16.0, endIndent: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}
