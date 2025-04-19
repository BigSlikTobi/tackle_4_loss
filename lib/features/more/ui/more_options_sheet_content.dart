import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tackle_4_loss/features/all_news/ui/all_news_screen.dart';
// --- Import the Settings Screen ---
import 'package:tackle_4_loss/features/settings/ui/settings_screen.dart';
// import 'package:url_launcher/url_launcher.dart'; // Keep commented for now

class MoreOptionsSheetContent extends ConsumerWidget {
  const MoreOptionsSheetContent({super.key});

  // --- Control visibility of the social media links ---
  final bool _showSocialLinks = true; // Set to false to hide them

  // --- Helper function to build consistent list items ---
  Widget _buildMoreListItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap, // Action to perform AFTER dismissing the sheet
    Color? iconColor,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      // Use ListTile directly, Card is less common inside bottom sheets unless needed
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 8.0,
      ),
      leading: Icon(icon, color: iconColor ?? theme.colorScheme.primary),
      title: Text(title, style: theme.textTheme.titleMedium),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
      onTap: () {
        // --- 1. Dismiss the Bottom Sheet First ---
        Navigator.pop(context);
        // --- 2. Perform the actual action ---
        onTap();
      },
    );
  }

  // --- Helper for Social Icon Buttons (Optional but good practice) ---
  Widget _buildSocialButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(icon),
      iconSize: 30.0,
      tooltip: tooltip,
      onPressed:
          onPressed, // Keep simple for now, handle dismiss/URL outside if needed
      color: Colors.grey[700], // Give social icons a distinct color
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // --- Return the ListView directly, maybe wrapped in Padding ---
    // Use MediaQuery to add padding respecting the bottom system inset (like home bar)
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Padding(
      // Add padding: top for spacing, bottom for system areas
      padding: EdgeInsets.only(
        top: 16.0,
        bottom: bottomPadding > 0 ? bottomPadding : 16.0,
      ),
      child: ListView(
        shrinkWrap: true, // Important for bottom sheet height calculation
        children: [
          _buildMoreListItem(
            context: context,
            icon: Icons.newspaper,
            title: 'All News',
            onTap: () {
              debugPrint('All News tapped - Navigating to AllNewsScreen');
              // Use root navigator if inside nested navigator, but usually fine
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AllNewsScreen()),
              );
            },
          ),
          _buildMoreListItem(
            context: context,
            icon: Icons.group,
            title: 'Teams',
            onTap: () {
              debugPrint('Teams tapped');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Navigate to Teams (Not Implemented)'),
                ),
              );
            },
          ),
          _buildMoreListItem(
            context: context,
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: () {
              debugPrint('Settings tapped - Navigating to SettingsScreen');
              // --- Navigate to the new Settings Screen ---
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
              // --- End Navigation ---
            },
          ),

          // --- Optional Social Media Links Section ---
          if (_showSocialLinks) ...[
            const Divider(
              height: 32,
              indent: 24,
              endIndent: 24,
            ), // Add a visual separator
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSocialButton(
                    icon: Icons.discord,
                    tooltip: 'Join our Discord',
                    onPressed: () {
                      debugPrint('Discord tapped');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Launch Discord (Not Implemented)'),
                        ),
                      );
                    },
                  ),
                  _buildSocialButton(
                    icon: Icons.camera_alt_outlined,
                    tooltip: 'Follow us on Instagram',
                    onPressed: () {
                      debugPrint('Instagram tapped');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Launch Instagram (Not Implemented)'),
                        ),
                      );
                    },
                  ),
                  _buildSocialButton(
                    icon: Icons.play_circle_outline,
                    tooltip: 'Subscribe on YouTube',
                    onPressed: () {
                      debugPrint('YouTube tapped');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Launch YouTube (Not Implemented)'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
          // No extra SizedBox needed if using bottom padding on the outer Padding
        ],
      ),
    );
  }
}
