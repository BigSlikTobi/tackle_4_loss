import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tackle_4_loss/core/providers/beta_banner_provider.dart';
import 'package:tackle_4_loss/core/providers/locale_provider.dart';
import 'package:tackle_4_loss/core/constants/layout_constants.dart';
import 'package:tackle_4_loss/core/theme/app_colors.dart'; // Import AppColors
import 'package:flutter/foundation.dart' show kIsWeb;

class BetaBanner extends ConsumerWidget {
  const BetaBanner({super.key});

  // Localized text content
  static const Map<String, Map<String, String>> _localizedContent = {
    'en': {
      'title': 'Public Beta',
      'description': 'You\'re using a beta version of Tackle4Loss.',
      'feedback': 'Share feedback and find the  @',
      'discord': '@ T4L Discord',
      'close': 'Close',
    },
    'de': {
      'title': 'Public Beta',
      'description': 'Dies ist eine Beta-Version von Tackle4Loss.',
      'feedback':
          'Hilf uns und gib uns Feedback in Discord. Dort findest du auch die iOS App @.', // Corrected German typo
      'discord': 'T4L @ Discord',
      'close': 'Schließen',
    },
  };

  static const String discordUrl = 'https://discord.gg/PfvQdPVh';

  Future<void> _launchDiscord(BuildContext context) async {
    try {
      final uri = Uri.parse(discordUrl);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open Discord link'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error launching Discord URL: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open Discord link'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVisible = ref.watch(betaBannerNotifierProvider);
    final currentLocale = ref.watch(localeNotifierProvider);
    final bannerNotifier = ref.read(betaBannerNotifierProvider.notifier);

    if (!isVisible) return const SizedBox.shrink();

    final theme = Theme.of(context); // Keep for text styles if needed
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < kMobileLayoutBreakpoint;

    // Get localized content
    final content =
        _localizedContent[currentLocale.languageCode] ??
        _localizedContent['en']!;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primaryGreen, // Use AppColors.primaryGreen
        // Consider removing the border or using a subtle shade from AppColors
        // border: Border(
        //   top: BorderSide(
        //     color: AppColors.white.withAlpha(50), // Example: subtle white border
        //     width: 1,
        //   ),
        // ),
      ),
      child: SafeArea(
        top: false, // Keep SafeArea for bottom
        bottom:
            true, // Ensure banner content is not obscured by system UI at the bottom
        child: Container(
          constraints:
              isMobile
                  ? null
                  : const BoxConstraints(maxWidth: kMaxContentWidth),
          margin: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 16),
          child: Padding(
            padding: EdgeInsets.only(
              left: isMobile ? 12 : 16, // Adjusted padding
              right: isMobile ? 8 : 12, // Adjusted padding
              top: isMobile ? 8 : 10, // Adjusted padding
              bottom: isMobile ? 4 : 10, // Adjusted padding
            ),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Center items vertically
              children: [
                // App Icon
                Padding(
                  padding: const EdgeInsets.only(
                    right: 12.0,
                  ), // Space between icon and text
                  child: Image.asset(
                    kIsWeb
                        ? '/icon/app_icon.png'
                        : 'assets/icon/app_icon.png', // Conditional path
                    height: isMobile ? 36 : 40, // Adjust size as needed
                    width: isMobile ? 36 : 40, // Adjust size as needed
                  ),
                ),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        content['title']!,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.white, // Use AppColors.white
                        ),
                      ),
                      const SizedBox(height: 2),

                      // Description and Discord link
                      GestureDetector(
                        onTap: () => _launchDiscord(context),
                        child: RichText(
                          text: TextSpan(
                            text: '${content['description']!} ',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.white.withAlpha(
                                220,
                              ), // Lighter white
                            ),
                            children: [
                              TextSpan(
                                text:
                                    isMobile
                                        ? '${content['feedback']!} '
                                        : '${content['feedback']!} ',
                              ),
                              WidgetSpan(
                                alignment:
                                    PlaceholderAlignment
                                        .middle, // Align icon with text
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4.0,
                                  ), // Add some spacing around the icon
                                  child: Icon(
                                    Icons
                                        .discord, // Corrected to use MaterialIcons.discord
                                    size:
                                        (theme.textTheme.bodySmall?.fontSize ??
                                            24) *
                                        2, // Increased size by 50%
                                    color: AppColors.white, // Icon color
                                  ),
                                ),
                              ),
                              if (!isMobile) const TextSpan(text: '.'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Close button
                IconButton(
                  onPressed: () => bannerNotifier.dismissBanner(),
                  icon: Icon(
                    Icons.close,
                    size: 20, // Slightly larger for better touch target
                    color: AppColors.white.withAlpha(
                      200,
                    ), // Use AppColors.white
                  ),
                  tooltip: content['close'],
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero, // Reduce padding around icon button
                  constraints: const BoxConstraints(
                    // Ensure consistent tap area
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
