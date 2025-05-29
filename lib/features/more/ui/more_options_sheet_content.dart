// lib/features/more/ui/more_options_sheet_content.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class MoreOptionsSheetContent extends ConsumerWidget {
  const MoreOptionsSheetContent({super.key});

  final bool _showSocialLinks = true;

  Widget _buildMoreListItem({
    required BuildContext dialogContext,
    required BuildContext appNavigatorContext,
    IconData? icon,
    String? assetIconPath,
    required String title,
    required VoidCallback onTapAction,
    Color? iconColor,
  }) {
    final theme = Theme.of(dialogContext);
    Widget leadingWidget;
    if (assetIconPath != null) {
      leadingWidget = Image.asset(
        assetIconPath,
        height: 28,
        width: 28,
        fit: BoxFit.contain,
        errorBuilder:
            (context, error, stackTrace) =>
                icon != null
                    ? Icon(icon, color: iconColor ?? theme.colorScheme.primary)
                    : const Icon(Icons.help_outline),
      );
    } else {
      leadingWidget = Icon(icon, color: iconColor ?? theme.colorScheme.primary);
    }
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 8.0,
      ),
      leading: leadingWidget,
      title: Text(title, style: theme.textTheme.titleMedium),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
      onTap: () {
        debugPrint(
          "[MoreOptionsSheetContent _buildMoreListItem onTap] Tapped on: $title",
        );
        onTapAction();

        if (Navigator.canPop(dialogContext)) {
          Navigator.pop(dialogContext);
          debugPrint(
            "[MoreOptionsSheetContent _buildMoreListItem onTap] Popped dialog for: $title",
          );
        } else {
          debugPrint(
            "[MoreOptionsSheetContent _buildMoreListItem onTap] Dialog for $title could not be popped (already popped or not active).",
          );
        }
      },
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(icon),
      iconSize: 30.0,
      tooltip: tooltip,
      onPressed: onPressed,
      color: Colors.grey[700],
    );
  }

  Future<void> _launchDiscord(BuildContext context) async {
    final Uri discordUrl = Uri.parse('https://discord.gg/PfvQdPVh');
    try {
      if (!await launchUrl(discordUrl, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open Discord link')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error launching Discord URL: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error opening Discord link')),
        );
      }
    }
  }

  void _navigateTo(BuildContext context, String path) {
    final rootNavigatorContext =
        GoRouter.of(context).routerDelegate.navigatorKey.currentContext;
    final currentLocation =
        GoRouter.of(context).routeInformationProvider.value.uri.toString();
    debugPrint(
      "[MoreOptionsSheetContent _navigateTo] Current router location: $currentLocation. Attempting to push '$path' onto root navigator.",
    );

    if (rootNavigatorContext != null) {
      GoRouter.of(rootNavigatorContext).push(path);
      debugPrint(
        "[MoreOptionsSheetContent _navigateTo] Pushed '$path' using rootNavigatorContext.",
      );
    } else {
      debugPrint(
        "[MoreOptionsSheetContent _navigateTo] ERROR: Root navigator context is null. Falling back to standard context.push for '$path'.",
      );
      GoRouter.of(
        context,
      ).push(path); // Fallback, though this might be the problematic one
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BuildContext appNavigatorContextForNavigation =
        context; // Using the sheet's context for router access
    debugPrint(
      "[MoreOptionsSheetContent build] appNavigatorContextForNavigation hash: ${appNavigatorContextForNavigation.hashCode}",
    );

    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.only(
        top: 16.0,
        bottom: bottomPadding > 0 ? bottomPadding : 16.0,
      ),
      child: ListView(
        shrinkWrap: true,
        children: [
          _buildMoreListItem(
            dialogContext: context,
            appNavigatorContext: appNavigatorContextForNavigation,
            assetIconPath: 'assets/navigation/news.png',
            icon: Icons.newspaper,
            title: 'All News',
            onTapAction:
                () =>
                    _navigateTo(appNavigatorContextForNavigation, '/all-news'),
          ),
          _buildMoreListItem(
            dialogContext: context,
            appNavigatorContext: appNavigatorContextForNavigation,
            assetIconPath: 'assets/navigation/teams.png',
            icon: Icons.group,
            title: 'Teams',
            onTapAction:
                () => _navigateTo(appNavigatorContextForNavigation, '/teams'),
          ),
          _buildMoreListItem(
            dialogContext: context,
            appNavigatorContext: appNavigatorContextForNavigation,
            assetIconPath: 'assets/navigation/standings.png',
            icon: Icons.leaderboard,
            title: 'Standings',
            onTapAction:
                () =>
                    _navigateTo(appNavigatorContextForNavigation, '/standings'),
          ),
          _buildMoreListItem(
            dialogContext: context,
            appNavigatorContext: appNavigatorContextForNavigation,
            assetIconPath: 'assets/navigation/settings.png',
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTapAction:
                () =>
                    _navigateTo(appNavigatorContextForNavigation, '/settings'),
          ),
          _buildMoreListItem(
            dialogContext: context,
            appNavigatorContext: appNavigatorContextForNavigation,
            icon: Icons.privacy_tip_outlined,
            title: 'Terms & Privacy',
            onTapAction:
                () => _navigateTo(
                  appNavigatorContextForNavigation,
                  '/terms-privacy',
                ),
          ),

          _buildMoreListItem(
            dialogContext: context,
            appNavigatorContext: appNavigatorContextForNavigation,
            icon: Icons.info_outline, // Or another suitable icon
            title: 'Impressum / Imprint',
            onTapAction:
                () =>
                    _navigateTo(appNavigatorContextForNavigation, '/impressum'),
          ),

          if (_showSocialLinks) ...[
            const Divider(height: 32, indent: 24, endIndent: 24),
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
                      debugPrint('Discord tapped - Opening Discord channel');
                      _launchDiscord(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
