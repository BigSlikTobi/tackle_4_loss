// lib/features/article_detail/ui/article_detail_screen.dart
// lib/features/article_detail/ui/article_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter for pop
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:share_plus/share_plus.dart';

import 'package:tackle_4_loss/core/widgets/global_app_bar.dart';
import 'package:tackle_4_loss/core/widgets/loading_indicator.dart';
import 'package:tackle_4_loss/core/widgets/error_message.dart';
import 'package:tackle_4_loss/core/providers/locale_provider.dart';
import 'package:tackle_4_loss/features/article_detail/logic/article_detail_provider.dart';
// import 'package:tackle_4_loss/core/providers/navigation_provider.dart'; // Removed currentDetailArticleIdProvider
import 'package:tackle_4_loss/core/constants/layout_constants.dart';
import 'package:tackle_4_loss/core/theme/app_colors.dart';
import 'package:tackle_4_loss/core/widgets/web_detail_wrapper.dart';

class ArticleDetailScreen extends ConsumerWidget {
  final int articleId;

  const ArticleDetailScreen({super.key, required this.articleId});

  Future<void> _launchUrl(Uri url, BuildContext context, WidgetRef ref) async {
    // ref is not used in this method currently, but kept for future consistency if needed
    final articleValue = ref.read(articleDetailProvider(articleId)).valueOrNull;
    final sourceDomain =
        articleValue?.sourceUrl != null
            ? Uri.parse(articleValue!.sourceUrl!).host
            : null;
    final targetDomain = url.host;

    if (sourceDomain != null && targetDomain == sourceDomain) {
      debugPrint("Attempted to open internal link: $url. Opening externally.");
    }

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not launch $url')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articleAsyncValue = ref.watch(articleDetailProvider(articleId));
    final currentLocale = ref.watch(localeNotifierProvider);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    debugPrint(
      'ArticleDetailScreen: Building screen for articleId: $articleId',
    );

    Widget? leadingWidget;
    // The GlobalAppBar will determine its leading widget based on GoRouter.canPop()
    // If a specific behavior is needed for this screen's back button beyond default pop,
    // it can be provided via the `leading` parameter to GlobalAppBar.
    // For now, let GlobalAppBar handle it.
    // Example: if we needed to do something specific before popping:
    // if (GoRouter.of(context).canPop()) {
    //   leadingWidget = IconButton(
    //     icon: const Icon(Icons.arrow_back_ios), // Or Icons.arrow_back for Material
    //     tooltip: MaterialLocalizations.of(context).backButtonTooltip,
    //     onPressed: () {
    //       debugPrint('ArticleDetailScreen: Custom back logic if any, then pop.');
    //       // ref.read(currentDetailArticleIdProvider.notifier).state = null; // REMOVED THIS LINE
    //       GoRouter.of(context).pop();
    //     },
    //   );
    // }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: GlobalAppBar(
        // GlobalAppBar will handle its own back/home button now
        // leading: leadingWidget, // Let GlobalAppBar decide its leading widget
        automaticallyImplyLeading:
            true, // This ensures GlobalAppBar tries to show a back button if canPop
        actions: articleAsyncValue.maybeWhen(
          data:
              (article) => [
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    final title = article.getLocalizedHeadline(
                      currentLocale.languageCode,
                    );
                    final url = article.sourceUrl;
                    if (url != null) {
                      Share.share('$title\n\n$url');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No URL available to share'),
                        ),
                      );
                    }
                  },
                  tooltip: 'Share Article',
                ),
              ],
          orElse: () => null,
        ),
      ),
      body: WebDetailWrapper(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
            child: articleAsyncValue.when(
              loading: () => const Center(child: LoadingIndicator()),
              error:
                  (error, stackTrace) => Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ErrorMessageWidget(
                      message:
                          'Failed to load article details.\n${error.toString()}',
                      onRetry:
                          () =>
                              ref.invalidate(articleDetailProvider(articleId)),
                    ),
                  ),
              data: (article) {
                final localeCode = currentLocale.languageCode;
                final headline = article.getLocalizedHeadline(localeCode);
                final htmlContent = article.getLocalizedContent(localeCode);
                final primaryImageUrl = article.primaryImageUrl;
                final sourceUri =
                    article.sourceUrl != null
                        ? Uri.tryParse(article.sourceUrl!)
                        : null;

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        headline,
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (primaryImageUrl != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: CachedNetworkImage(
                              imageUrl: primaryImageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              placeholder:
                                  (context, url) => Container(
                                    height: 250,
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: LoadingIndicator(),
                                    ),
                                  ),
                              errorWidget:
                                  (context, url, error) => Container(
                                    height: 250,
                                    color: Colors.grey[200],
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      color: Colors.grey[500],
                                      size: 40,
                                    ),
                                  ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              article.sourceName ?? 'Unknown Source',
                              style: textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (article.createdAt != null)
                            Text(
                              DateFormat.yMMMd(
                                localeCode,
                              ).format(article.createdAt!),
                              style: textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      if (htmlContent != null && htmlContent.isNotEmpty)
                        Html(
                          data: htmlContent,
                          style: {
                            "body": Style(
                              fontSize: FontSize(
                                textTheme.bodyLarge?.fontSize ?? 16.0,
                              ),
                              color: textTheme.bodyLarge?.color,
                              lineHeight: LineHeight(
                                textTheme.bodyLarge?.height ?? 1.5,
                              ),
                              margin: Margins.zero,
                              padding: HtmlPaddings.zero,
                            ),
                            "p": Style(margin: Margins.only(bottom: 12.0)),
                            "a": Style(
                              color: theme.colorScheme.primary,
                              textDecoration: TextDecoration.underline,
                            ),
                            "h1": Style(
                              fontSize: FontSize(
                                textTheme.headlineSmall?.fontSize ?? 20.0,
                              ),
                              fontWeight: textTheme.headlineSmall?.fontWeight,
                              margin: Margins.symmetric(vertical: 10.0),
                            ),
                            "h2": Style(
                              fontSize: FontSize(
                                textTheme.titleLarge?.fontSize ?? 18.0,
                              ),
                              fontWeight: textTheme.titleLarge?.fontWeight,
                              margin: Margins.symmetric(vertical: 8.0),
                            ),
                          },
                          onLinkTap: (url, attributes, element) {
                            if (url != null) {
                              final uri = Uri.tryParse(url);
                              if (uri != null) {
                                _launchUrl(uri, context, ref);
                              } else {
                                debugPrint(
                                  "Could not parse URL from HTML link: $url",
                                );
                              }
                            }
                          },
                        )
                      else
                        Text(
                          'Article content is not available.',
                          style: textTheme.bodyLarge?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[600],
                          ),
                        ),
                      const SizedBox(height: 24),
                      if (sourceUri != null && article.sourceUrl != null)
                        Center(
                          child: TextButton.icon(
                            icon: const Icon(Icons.open_in_browser, size: 18),
                            label: Text(
                              'Read Full Article at ${article.sourceName ?? 'Source'}',
                            ),
                            onPressed:
                                () => _launchUrl(sourceUri, context, ref),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
