// lib/features/more/ui/more_options_sheet_content.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class MoreOptionsSheetContent extends ConsumerWidget {
  const MoreOptionsSheetContent({super.key});

  final bool _showSocialLinks = true;

  Widget _buildMoreListItem({
    required BuildContext
    dialogContext, // Context of the dialog/sheet for theming and pop
    required BuildContext
    appNavigatorContext, // Context from the main app (that has GoRouter) for navigation
    IconData? icon,
    String? assetIconPath,
    required String title,
    required VoidCallback onTapAction, // This will contain the context.go()
    Color? iconColor,
  }) {
    final theme = Theme.of(
      dialogContext,
    ); // Use dialogContext for theming inside the sheet
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BuildContext appNavigatorContextForGoRouter = context;
    debugPrint(
      "[MoreOptionsSheetContent build] appNavigatorContextForGoRouter hash: ${appNavigatorContextForGoRouter.hashCode}",
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
            appNavigatorContext: appNavigatorContextForGoRouter,
            assetIconPath: 'assets/navigation/news.png',
            icon: Icons.newspaper,
            title: 'All News',
            onTapAction: () {
              final currentLocation =
                  GoRouter.of(
                    appNavigatorContextForGoRouter,
                  ).routeInformationProvider.value.uri.toString();
              debugPrint(
                "[MoreOptionsSheetContent] All News action. Current router location: $currentLocation. Navigating to /all-news with context.go()",
              );
              GoRouter.of(appNavigatorContextForGoRouter).go('/all-news');
            },
          ),
          _buildMoreListItem(
            dialogContext: context,
            appNavigatorContext: appNavigatorContextForGoRouter,
            assetIconPath: 'assets/navigation/teams.png',
            icon: Icons.group,
            title: 'Teams',
            onTapAction: () {
              final currentLocation =
                  GoRouter.of(
                    appNavigatorContextForGoRouter,
                  ).routeInformationProvider.value.uri.toString();
              debugPrint(
                "[MoreOptionsSheetContent] Teams action. Current router location: $currentLocation. Navigating to /teams with context.go()",
              );
              GoRouter.of(appNavigatorContextForGoRouter).go('/teams');
            },
          ),
          _buildMoreListItem(
            dialogContext: context,
            appNavigatorContext: appNavigatorContextForGoRouter,
            assetIconPath: 'assets/navigation/standings.png',
            icon: Icons.leaderboard,
            title: 'Standings',
            onTapAction: () {
              final currentLocation =
                  GoRouter.of(
                    appNavigatorContextForGoRouter,
                  ).routeInformationProvider.value.uri.toString();
              debugPrint(
                "[MoreOptionsSheetContent] Standings action. Current router location: $currentLocation. Navigating to /standings with context.go()",
              );
              GoRouter.of(appNavigatorContextForGoRouter).go('/standings');
            },
          ),
          _buildMoreListItem(
            dialogContext: context,
            appNavigatorContext: appNavigatorContextForGoRouter,
            assetIconPath: 'assets/navigation/settings.png',
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTapAction: () {
              final currentLocation =
                  GoRouter.of(
                    appNavigatorContextForGoRouter,
                  ).routeInformationProvider.value.uri.toString();
              debugPrint(
                "[MoreOptionsSheetContent] Settings action. Current router location: $currentLocation. Navigating to /settings with context.go()",
              );
              GoRouter.of(appNavigatorContextForGoRouter).go('/settings');
            },
          ),
          _buildMoreListItem(
            dialogContext: context,
            appNavigatorContext: appNavigatorContextForGoRouter,
            icon: Icons.privacy_tip_outlined,
            title: 'Terms & Privacy',
            onTapAction: () {
              final currentLocation =
                  GoRouter.of(
                    appNavigatorContextForGoRouter,
                  ).routeInformationProvider.value.uri.toString();
              debugPrint(
                "[MoreOptionsSheetContent] Terms & Privacy action. Current router location: $currentLocation. Navigating to /terms-privacy with context.go()",
              );
              GoRouter.of(appNavigatorContextForGoRouter).go('/terms-privacy');
            },
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
