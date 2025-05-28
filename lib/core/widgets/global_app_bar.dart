// lib/core/widgets/global_app_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:tackle_4_loss/core/theme/app_colors.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class GlobalAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final bool
  automaticallyImplyLeading; // Keep this for explicitness from parent
  final Widget? leading; // Allow parent to override leading

  static const double _logoHeightParam = 150; // Base height for logo parts
  static const double _logoWidthParam = 200.0; // Base width for logo parts
  static const double _webScaleFactor = 1.5; // Scale factor for web
  static final double _webToolbarHeight = kToolbarHeight * _webScaleFactor;

  const GlobalAppBar({
    super.key,
    this.title,
    this.actions,
    this.automaticallyImplyLeading =
        true, // Default to true, but can be overridden
    this.leading,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iconTheme = Theme.of(context).iconTheme;
    final bool isCurrentlyWeb = kIsWeb;
    final double currentToolbarHeight =
        isCurrentlyWeb ? _webToolbarHeight : kToolbarHeight;

    final defaultTitle = Image.asset(
      'assets/images/logo.jpg',
      height:
          isCurrentlyWeb
              ? _logoHeightParam * _webScaleFactor
              : _logoHeightParam,
      width:
          isCurrentlyWeb ? _logoWidthParam * _webScaleFactor : _logoWidthParam,
      fit: BoxFit.contain,
    );

    Widget? finalLeadingWidget =
        leading; // Start with any provided leading widget

    if (finalLeadingWidget == null && automaticallyImplyLeading) {
      final router = GoRouter.of(context);
      final String currentLocation =
          router.routeInformationProvider.value.uri.path;
      final bool canPop = router.canPop(); // Use GoRouter's canPop

      // Define main shell routes where a 'Home' button might be redundant if !canPop
      const mainShellPaths = [
        '/',
        '/news',
        '/my-team',
        '/schedule',
        '/more-placeholder',
      ];

      final bool onMainShellTab = mainShellPaths.contains(currentLocation);

      debugPrint(
        "[GlobalAppBar build] Can Pop: $canPop, Current Location: $currentLocation, On Main Shell Tab: $onMainShellTab, Title: ${title.runtimeType}",
      );

      if (canPop) {
        finalLeadingWidget = IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () {
            debugPrint("[GlobalAppBar] Back button pressed. Popping route.");
            router.pop();
          },
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        );
      } else if (!onMainShellTab) {
        // Show Home button if cannot pop AND not on a main shell tab
        // This is primarily for mobile to escape screens navigated to with context.go()
        finalLeadingWidget = IconButton(
          icon: const Icon(Icons.home_outlined, color: AppColors.textPrimary),
          onPressed: () {
            debugPrint(
              "[GlobalAppBar] Home button pressed. Navigating to '/' with context.go().",
            );
            context.go('/');
          },
          tooltip: 'Go Home',
        );
      }
      // If !canPop AND onMainShellTab, no leading icon is shown (unless 'leading' was explicitly provided)
    }

    return AppBar(
      toolbarHeight: currentToolbarHeight,
      backgroundColor: AppColors.backgroundLight,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      shadowColor: Colors.black.withAlpha(26),
      centerTitle: true,
      leading: finalLeadingWidget, // Use the determined leading widget
      automaticallyImplyLeading: false, // We are handling it explicitly
      shape: const Border(
        bottom: BorderSide(color: AppColors.dividerLight, width: 1.0),
      ),
      title: title ?? defaultTitle,
      actionsIconTheme: iconTheme.copyWith(color: AppColors.textPrimary),
      actions: actions,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kIsWeb ? _webToolbarHeight : kToolbarHeight);
}
