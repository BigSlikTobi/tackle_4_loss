// lib/core/widgets/global_app_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Locale provider no longer directly needed here
// import 'package:your_project_name/core/providers/locale_provider.dart';
import 'package:tackle_4_loss/core/theme/app_colors.dart';

// Keep as ConsumerWidget only if other passed actions might need ref
class GlobalAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions; // Actions passed from parent screen
  final bool automaticallyImplyLeading;
  final Widget? leading; // Leading passed from parent screen (e.g., menu icon)

  const GlobalAppBar({
    super.key,
    this.title,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.leading,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keep ref if ConsumerWidget
    final iconTheme = Theme.of(context).iconTheme;
    // final currentLocale = ref.watch(localeNotifierProvider); // Remove

    // Use only actions passed from the parent screen
    List<Widget> effectiveActions =
        actions ?? []; // Default to empty list if null

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
