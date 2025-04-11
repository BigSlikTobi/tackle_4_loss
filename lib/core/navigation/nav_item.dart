import 'package:flutter/material.dart';

class NavItem {
  final String label;
  final IconData icon; // Icon for bottom nav
  final Widget screen; // The screen widget to navigate to

  const NavItem({
    required this.label,
    required this.icon,
    required this.screen,
  });
}
