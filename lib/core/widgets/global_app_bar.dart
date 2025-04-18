// lib/core/widgets/global_app_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tackle_4_loss/core/theme/app_colors.dart';
import 'package:tackle_4_loss/core/constants/team_constants.dart';

// Keep as ConsumerWidget only if other passed actions might need ref
class GlobalAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions; // Actions passed from parent screen
  final bool automaticallyImplyLeading;
  final Widget? leading; // Leading passed from parent screen (e.g., menu icon)
  final String? teamId; // Added parameter for the selected team ID

  const GlobalAppBar({
    super.key,
    this.title,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.leading,
    this.teamId, // New parameter
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keep ref if ConsumerWidget
    final iconTheme = Theme.of(context).iconTheme;

    // Use only actions passed from the parent screen
    List<Widget> effectiveActions = [
      ...(actions ?? []),
    ]; // Default to empty list if null

    // Add team logo to actions if teamId is provided
    if (teamId != null && teamLogoMap.containsKey(teamId)) {
      effectiveActions.add(
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: SizedBox(
            width: 32,
            height: 32,
            child: Image.asset(
              'assets/team_logos/${teamLogoMap[teamId]}.png',
              fit: BoxFit.contain,
              errorBuilder:
                  (context, error, stackTrace) => const SizedBox.shrink(),
            ),
          ),
        ),
      );
    }

    return AppBar(
      backgroundColor: AppColors.backgroundLight,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      shadowColor: Colors.black.withAlpha(
        26,
      ), // Use withAlpha instead of withOpacity
      centerTitle: true,
      // Use leading passed from MainNavigationWrapper or handle back button
      leading:
          leading ??
          (automaticallyImplyLeading
              ? IconButton(
                icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              )
              : null),
      automaticallyImplyLeading: false, // Leading is handled explicitly
      shape: const Border(
        bottom: BorderSide(color: AppColors.dividerLight, width: 1.0),
      ),
      title: title ?? Image.asset('assets/images/logo.jpg', height: 150),
      actionsIconTheme: iconTheme.copyWith(color: AppColors.textPrimary),
      actions: effectiveActions, // Use the potentially empty actions list
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
