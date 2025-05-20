import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/schedule_model.dart';
import '../data/schedule_providers.dart';
import 'game_card.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final selectedWeek = ref.read(selectedWeekProvider);
    final weekOptions = ref.read(weekOptionsProvider);
    final initialPage = weekOptions.indexOf(selectedWeek);
    _pageController = PageController(initialPage: initialPage);
    _tabController = TabController(length: weekOptions.length, vsync: this, initialIndex: initialPage);
    // Remove indexIsChanging logic, handle tab taps in TabBar's onTap
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedWeek = ref.watch(selectedWeekProvider);
    final weekOptions = ref.watch(weekOptionsProvider);
    final weekLabels = ref.watch(weekLabelProvider);
    final scheduleAsync = ref.watch(scheduleProvider);

    // Update tab controller if weekOptions changes
    if (_tabController.length != weekOptions.length) {
      _tabController.dispose();
      _tabController = TabController(length: weekOptions.length, vsync: this, initialIndex: weekOptions.indexOf(selectedWeek));
    }
    if (_tabController.index != weekOptions.indexOf(selectedWeek)) {
      _tabController.index = weekOptions.indexOf(selectedWeek);
    }

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Compact sliding week header
              Material(
                color: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).primaryColor,
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabs: [
                    for (final week in weekOptions)
                      Tab(text: weekLabels[week] ?? 'Week $week'),
                  ],
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
                  labelColor: Theme.of(context).appBarTheme.foregroundColor ?? Colors.white,
                  unselectedLabelColor: (Theme.of(context).appBarTheme.foregroundColor ?? Colors.white).withAlpha((0.7 * 255).toInt()),
                  indicatorColor: Theme.of(context).appBarTheme.foregroundColor ?? Colors.white,
                  onTap: (index) {
                    // Log for validation
                    // print('TabBar tapped: $index');
                    ref.read(selectedWeekProvider.notifier).state = weekOptions[index];
                    _pageController.jumpToPage(index);
                  },
                ),
              ),
              const SizedBox(height: 8),
              // Schedule content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: weekOptions.length,
                  onPageChanged: (index) {
                    ref.read(selectedWeekProvider.notifier).state = weekOptions[index];
                    if (_tabController.index != index) {
                      _tabController.animateTo(index);
                    }
                  },
                  itemBuilder: (context, index) {
                    return scheduleAsync.when(
                      data: (games) {
                        if (games.isEmpty) {
                          return const Center(
                            child: Text('No games scheduled for this week'),
                          );
                        }

                        // Sort games by date/time
                        final sortedGames = List<ScheduleGame>.from(games)
                          ..sort((a, b) {
                            final dateComparison = a.date.compareTo(b.date);
                            if (dateComparison != 0) return dateComparison;
                            
                            // If dates are equal, compare by time (if available)
                            if (a.time == null && b.time == null) return 0;
                            if (a.time == null) return 1;
                            if (b.time == null) return -1;
                            return a.time!.compareTo(b.time!);
                          });

                        return RefreshIndicator(
                          onRefresh: () async {
                            return ref.refresh(scheduleProvider);
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: sortedGames.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: GameCard(game: sortedGames[index]),
                              );
                            },
                          ),
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (error, stackTrace) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error_outline, size: 48, color: Colors.red),
                              const SizedBox(height: 16),
                              Text(
                                'Error loading schedule data',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                error.toString(),
                                style: Theme.of(context).textTheme.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => ref.refresh(scheduleProvider),
                                child: const Text('Try Again'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
