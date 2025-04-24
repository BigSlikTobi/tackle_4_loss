import 'package:flutter/material.dart';
import 'package:tackle_4_loss/core/navigation/nav_item.dart';
// --- Make sure these imports match your file structure ---
import 'package:tackle_4_loss/features/news_feed/ui/news_feed_screen.dart';
import 'package:tackle_4_loss/features/my_team/ui/my_team_screen.dart';
import 'package:tackle_4_loss/features/schedule/ui/schedule_screen.dart';
// import 'package:tackle_4_loss/features/more/ui/more_screen.dart'; // No longer needed
// --- End Imports ---

// Keep the list final, but remove const from the NavItem instances inside
final List<NavItem> appNavItems = [
  NavItem(
    label: 'News',
    assetIconPath: 'assets/navigation/home.png',
    screen: NewsFeedScreen(),
  ),
  NavItem(
    label: 'My Team',
    icon: Icons.people,
    screen: MyTeamScreen(),
    teamId: null, // This will be dynamically set based on user preference
  ),
  NavItem(
    label: 'Schedule',
    assetIconPath: 'assets/navigation/standings.png',
    screen: ScheduleScreen(),
  ),
  NavItem(
    label: 'More',
    assetIconPath: 'assets/navigation/more.png',
    screen: const SizedBox.shrink(),
  ),
];
