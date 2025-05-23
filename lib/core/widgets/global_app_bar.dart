import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Keep if actions might need ref
import 'package:tackle_4_loss/core/theme/app_colors.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb; // Ensure kIsWeb is available

// Keep as ConsumerWidget only if passed actions might need ref, otherwise StatelessWidget
class GlobalAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final Widget? title; // Screen can provide a specific title widget
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final Widget? leading;
  // --- REMOVE teamId parameter ---
  // final String? teamId;

  // Define constants for original heights and scale factor
  static const double _originalImageHeightParam = 150.0;
  static const double _webScaleFactor = 1.5;

  // Calculate web-specific heights
  static final double _webToolbarHeight = kToolbarHeight * _webScaleFactor;
  static final double _webImageHeightParam =
      _originalImageHeightParam * _webScaleFactor;

  const GlobalAppBar({
    super.key,
    this.title,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.leading,
    // this.teamId, // Removed
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keep ref if ConsumerWidget
    final iconTheme = Theme.of(context).iconTheme;

    // Determine current platform's heights
    final bool isCurrentlyWeb = kIsWeb;
    final double currentToolbarHeight =
        isCurrentlyWeb ? _webToolbarHeight : kToolbarHeight;
    final double currentImageHeightParam =
        isCurrentlyWeb ? _webImageHeightParam : _originalImageHeightParam;

    final defaultTitle = Image.asset(
      'assets/images/logo.jpg',
      height: currentImageHeightParam, // Use dynamic height
    ); // Default app logo

    debugPrint(
      "GlobalAppBar build: title parameter is ${title == null ? 'null' : 'provided'}",
    );
    if (title == null) {
      debugPrint("GlobalAppBar build: Using default Image logo.");
    } else {
      debugPrint(
        "GlobalAppBar build: Using provided title widget: ${title.runtimeType}",
      );
    }

    return AppBar(
      toolbarHeight: currentToolbarHeight, // Set dynamic toolbar height
      backgroundColor: AppColors.backgroundLight,
      foregroundColor:
          AppColors
              .textPrimary, // This should set the default color for text and icons
      elevation: 0,
      scrolledUnderElevation: 0.5,
      shadowColor: Colors.black.withAlpha(26),
      centerTitle: true, // Ensure title is centered
      // Use leading passed from parent or handle back button
      leading:
          leading ??
          (automaticallyImplyLeading &&
                  Navigator.canPop(context) // Only show back arrow if possible
              ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: AppColors.textPrimary,
                ),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              )
              : null),
      automaticallyImplyLeading: false, // Leading is handled explicitly above
      shape: const Border(
        bottom: BorderSide(color: AppColors.dividerLight, width: 1.0),
      ),
      // --- Use provided title OR the default app logo ---
      title: title ?? defaultTitle,
      actionsIconTheme: iconTheme.copyWith(color: AppColors.textPrimary),
      actions: actions, // Use actions passed from parent
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kIsWeb ? _webToolbarHeight : kToolbarHeight);
}
