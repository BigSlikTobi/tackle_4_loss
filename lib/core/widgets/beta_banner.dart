import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tackle_4_loss/core/providers/beta_banner_provider.dart';
import 'package:tackle_4_loss/core/providers/locale_provider.dart';
import 'package:tackle_4_loss/core/constants/layout_constants.dart';

class BetaBanner extends ConsumerWidget {
  const BetaBanner({super.key});

  // Localized text content
  static const Map<String, Map<String, String>> _localizedContent = {
    'en': {
      'title': 'Public Beta',
      'description': 'You\'re using a beta version of Tackle4Loss.',
      'feedback': 'Share feedback and find the iOS app',
      'discord': '@ T4L Discord',
      'close': 'Close',
    },
    'de': {
      'title': 'Public Beta',
      'description': 'Dies ist eine Beta-Version von Tackle4Loss',
      'feedback':
          'Hilf uns und gib uns feedback in Discord. Dort findest du auch die iOS App.',
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

    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < kMobileLayoutBreakpoint;

    // Get localized content
    final content =
        _localizedContent[currentLocale.languageCode] ??
        _localizedContent['en']!;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withAlpha(230),
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.primary.withAlpha(100),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          constraints:
              isMobile
                  ? null
                  : const BoxConstraints(maxWidth: kMaxContentWidth),
          margin: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 16),
          child: Padding(
            padding: EdgeInsets.only(
              left: isMobile ? 16 : 20,
              right: isMobile ? 16 : 20,
              top: 8,
              bottom: 4,
            ),
            child: Row(
              children: [
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
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 2),

                      // Description and Discord link
                      if (isMobile) ...[
                        // Mobile: Stack vertically
                        Text(
                          content['description']!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer
                                .withAlpha(200),
                          ),
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () => _launchDiscord(context),
                          child: RichText(
                            text: TextSpan(
                              text: '${content['feedback']!} ',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer
                                    .withAlpha(200),
                              ),
                              children: [
                                TextSpan(
                                  text: content['discord']!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ] else ...[
                        // Desktop: Inline
                        GestureDetector(
                          onTap: () => _launchDiscord(context),
                          child: RichText(
                            text: TextSpan(
                              text: '${content['description']!} ',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer
                                    .withAlpha(200),
                              ),
                              children: [
                                TextSpan(text: '${content['feedback']!} '),
                                TextSpan(
                                  text: content['discord']!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                const TextSpan(text: '.'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Close button
                IconButton(
                  onPressed: () => bannerNotifier.dismissBanner(),
                  icon: Icon(
                    Icons.close,
                    size: 18,
                    color: theme.colorScheme.onPrimaryContainer.withAlpha(180),
                  ),
                  tooltip: content['close'],
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
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
