import 'package:flutter/material.dart';
import 'package:tackle_4_loss/core/navigation/nav_item.dart';
import 'package:tackle_4_loss/features/news_feed/ui/news_feed_screen.dart';
import 'package:tackle_4_loss/features/my_team/ui/my_team_screen.dart';
import 'package:tackle_4_loss/features/schedule/ui/schedule_screen.dart';
import 'package:tackle_4_loss/features/more/ui/more_screen.dart';

final List<NavItem> appNavItems = [
  const NavItem(label: 'News', icon: Icons.newspaper, screen: NewsFeedScreen()),
  const NavItem(label: 'My Team', icon: Icons.people, screen: MyTeamScreen()),
  const NavItem(
    label: 'Schedule',
    icon: Icons.calendar_month,
    screen: ScheduleScreen(),
  ),
  const NavItem(label: 'More', icon: Icons.more_horiz, screen: MoreScreen()),
];
