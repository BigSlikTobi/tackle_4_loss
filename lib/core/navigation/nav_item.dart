import 'package:flutter/material.dart';

class NavItem {
  final String label;
  final IconData? icon; // IconData for default icon (nullable now)
  final String? assetIconPath; // Optional asset path for custom icon
  final Widget screen;
  final String? teamId;

  const NavItem({
    required this.label,
    this.icon,
    this.assetIconPath,
    required this.screen,
    this.teamId,
  });
}
