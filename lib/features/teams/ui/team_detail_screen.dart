import 'package:flutter/material.dart';
import 'package:tackle_4_loss/features/teams/data/team_info.dart';
import 'package:tackle_4_loss/core/constants/team_constants.dart';
import 'package:tackle_4_loss/features/teams/ui/widgets/placeholder_content.dart';
import 'package:tackle_4_loss/core/widgets/global_app_bar.dart';
import 'package:tackle_4_loss/core/constants/layout_constants.dart';
import 'package:tackle_4_loss/features/teams/ui/widgets/roster_tab_content.dart';
import 'package:tackle_4_loss/features/teams/ui/widgets/team_news_tab_content.dart';
// --- Import the new Game Day Tab content widget ---
import 'package:tackle_4_loss/features/teams/ui/widgets/game_day_tab_content.dart';

class TeamDetailScreen extends StatefulWidget {
  final TeamInfo teamInfo;

  const TeamDetailScreen({super.key, required this.teamInfo});

  @override
  State<TeamDetailScreen> createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends State<TeamDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Main tabs (remain the same)
  final List<Tab> _tabs = const <Tab>[
    Tab(text: 'General'),
    Tab(text: 'Roster'),
    Tab(text: 'Game Day'),
    Tab(text: 'News'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + kTextTabBarHeight),
        child: Column(
          children: [
            const GlobalAppBar(
              automaticallyImplyLeading: true, // Keep back button
            ),
            Material(
              color: theme.appBarTheme.backgroundColor ?? theme.primaryColor,
              child: TabBar(
                controller: _tabController,
                tabs: _tabs,
                isScrollable: true,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                ),
                labelColor: theme.appBarTheme.foregroundColor ?? Colors.white,
                unselectedLabelColor: (theme.appBarTheme.foregroundColor ??
                        Colors.white)
                    .withOpacity(0.7),
                indicatorColor:
                    theme.appBarTheme.foregroundColor ?? Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        // Keep stack for the badge
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
              child: TabBarView(
                controller: _tabController,
                children: <Widget>[
                  const PlaceholderContent(title: 'General Info'),
                  RosterTabContent(teamAbbreviation: widget.teamInfo.teamId),
                  // --- Replace Game Day placeholder ---
                  GameDayTabContent(teamAbbreviation: widget.teamInfo.teamId),
                  // --- End Replacement ---
                  TeamNewsTabContent(teamAbbreviation: widget.teamInfo.teamId),
                ],
              ),
            ),
          ),
          Positioned(
            left: 16.0,
            bottom: 16.0,
            child: _buildTeamLogoBadge(context, widget.teamInfo),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamLogoBadge(BuildContext context, TeamInfo teamInfo) {
    final logoPath = getTeamLogoPath(teamInfo.teamId);
    final theme = Theme.of(context);
    const double badgeSize = 55.0;

    return Container(
      width: badgeSize,
      height: badgeSize,
      decoration: BoxDecoration(
        color: theme.cardColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 6.0,
            spreadRadius: 1.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Image.asset(
            logoPath,
            fit: BoxFit.contain,
            errorBuilder: (ctx, err, st) {
              debugPrint("Error loading badge logo $logoPath: $err");
              return Icon(
                Icons.shield_outlined,
                size: badgeSize * 0.6,
                color: theme.disabledColor,
              );
            },
          ),
        ),
      ),
    );
  }
}
