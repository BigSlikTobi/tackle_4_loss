// lib/features/standings/ui/standings_view_selector.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tackle_4_loss/features/standings/logic/standings_provider.dart';

class StandingsViewSelector extends ConsumerWidget {
  const StandingsViewSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentViewType = ref.watch(standingsViewTypeProvider);
    final theme = Theme.of(context);

    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.dividerColor, width: 1.0),
        ),
      ),
      child: Row(
        children: [
          _buildTab(
            context,
            'League',
            StandingsViewType.nfl,
            currentViewType,
            ref,
          ),
          _buildTab(
            context,
            'Conference',
            StandingsViewType.conference,
            currentViewType,
            ref,
          ),
          _buildTab(
            context,
            'Division',
            StandingsViewType.division,
            currentViewType,
            ref,
          ),
        ],
      ),
    );
  }

  Widget _buildTab(
    BuildContext context,
    String label,
    StandingsViewType type,
    StandingsViewType currentType,
    WidgetRef ref,
  ) {
    final theme = Theme.of(context);
    final isSelected = type == currentType;

    return Expanded(
      child: InkWell(
        onTap: () {
          ref.read(standingsViewTypeProvider.notifier).state = type;
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color:
                    isSelected ? theme.colorScheme.primary : Colors.transparent,
                width: 2.0,
              ),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color:
                    isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 179),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
