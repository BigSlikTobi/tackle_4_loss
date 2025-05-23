import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:tackle_4_loss/features/news_feed/data/cluster_article.dart';
import 'package:tackle_4_loss/features/news_feed/logic/featured_cluster_provider.dart';
import 'package:tackle_4_loss/core/providers/locale_provider.dart';
import 'package:tackle_4_loss/core/widgets/loading_indicator.dart';
import 'package:tackle_4_loss/core/widgets/error_message.dart';
import 'package:tackle_4_loss/core/widgets/global_app_bar.dart'; // Import GlobalAppBar
import 'package:tackle_4_loss/core/widgets/web_detail_wrapper.dart'; // Import WebDetailWrapper
import 'package:flutter/foundation.dart'; // For kIsWeb

// Provider to manage the "show full content" state for the detail screen
final _showFullContentProvider = StateProvider.autoDispose<bool>(
  (ref) => false,
); // Changed to autoDispose

// Utility function to strip HTML tags (can be moved to a common utils file)
String _stripHtml(String htmlText) {
  final RegExp htmlRegExp = RegExp(
    r"<[^>]*>",
    multiLine: true,
    caseSensitive: true,
  );
  return htmlText
      .replaceAll(htmlRegExp, '')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .trim();
}

class ClusterArticleDetailScreen extends ConsumerWidget {
  final String clusterArticleId;

  const ClusterArticleDetailScreen({super.key, required this.clusterArticleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featuredClusterAsync = ref.watch(featuredClusterProvider);
    final currentLocale = ref.watch(localeNotifierProvider);
    final showFullContent = ref.watch(_showFullContentProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const GlobalAppBar(
        // Use GlobalAppBar
        // title parameter is intentionally omitted to show the default logo
      ),
      body: WebDetailWrapper(
        // Wrap the body's content
        child: featuredClusterAsync.when(
          data: (articles) {
            final article = articles.firstWhere(
              (art) => art.clusterArticleId == clusterArticleId,
              orElse:
                  () => ClusterArticle(
                    clusterArticleId: '',
                    createdAtStr: '',
                    englishHeadline: 'Article not found',
                    englishSummary: '',
                    englishContent: '',
                    sources: [],
                    deHeadline: 'Artikel nicht gefunden',
                    deSummary: '',
                    deContent: '',
                  ),
            );

            if (article.clusterArticleId.isEmpty) {
              return const Center(child: Text("Article not found."));
            }

            final rawHeadline =
                (currentLocale.languageCode == 'de' &&
                        article.deHeadline.isNotEmpty)
                    ? article.deHeadline
                    : (article.englishHeadline.isNotEmpty
                        ? article.englishHeadline
                        : "No Title");

            final headlineToShow = _stripHtml(rawHeadline);

            final summaryToShow =
                (currentLocale.languageCode == 'de' &&
                        article.deSummary.isNotEmpty)
                    ? article.deSummary
                    : article.englishSummary;

            final contentToShow =
                (currentLocale.languageCode == 'de' &&
                        article.deContent.isNotEmpty)
                    ? article.deContent
                    : article.englishContent;

            // Get unique source names
            final uniqueSourceNames =
                article.sources.map((s) => s.name).toSet().toList();

            // Get latest source date
            DateTime? latestSourceDate;
            if (article.sources.isNotEmpty) {
              final validDates =
                  article.sources
                      .map((source) => source.createdAt)
                      .whereType<DateTime>()
                      .toList();
              if (validDates.isNotEmpty) {
                validDates.sort((a, b) => b.compareTo(a));
                latestSourceDate = validDates.first;
              }
            }

            final displayDate = latestSourceDate ?? article.createdAt;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    headlineToShow,
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // Article Image
                  Builder(
                    builder: (context) {
                      Widget imageContent;
                      if (article.imageUrl != null &&
                          article.imageUrl!.isNotEmpty) {
                        if (kIsWeb) {
                          imageContent = CachedNetworkImage(
                            imageUrl: article.imageUrl!,
                            fit:
                                BoxFit
                                    .fitWidth, // Fit width, height is intrinsic, no truncation
                            width: double.infinity,
                            placeholder:
                                (context, url) => const AspectRatio(
                                  aspectRatio:
                                      16 /
                                      9, // Placeholder with common aspect ratio
                                  child: Center(child: LoadingIndicator()),
                                ),
                            errorWidget:
                                (context, url, error) => const AspectRatio(
                                  aspectRatio:
                                      16 /
                                      9, // Error widget with common aspect ratio
                                  child: Center(
                                    child: Icon(Icons.broken_image, size: 50),
                                  ),
                                ),
                          );
                        } else {
                          // Mobile - show full image without cropping
                          imageContent = CachedNetworkImage(
                            imageUrl: article.imageUrl!,
                            fit:
                                BoxFit
                                    .contain, // Changed to contain to show full image
                            width: double.infinity,
                            placeholder:
                                (context, url) => const AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: Center(child: LoadingIndicator()),
                                ),
                            errorWidget:
                                (context, url, error) => const AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: Center(
                                    child: Icon(Icons.broken_image, size: 50),
                                  ),
                                ),
                          );
                        }
                      } else {
                        // Fallback when no imageUrl
                        if (kIsWeb) {
                          imageContent = AspectRatio(
                            aspectRatio:
                                16 /
                                9, // Consistent aspect ratio for web fallback
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                // borderRadius is handled by ClipRRect
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                ),
                              ),
                            ),
                          );
                        } else {
                          // Mobile
                          imageContent = AspectRatio(
                            aspectRatio:
                                16 /
                                9, // Consistent aspect ratio for mobile fallback
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                // borderRadius is handled by ClipRRect
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                ),
                              ),
                            ),
                          );
                        }
                      }

                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: imageContent,
                      );
                    },
                  ),
                  const SizedBox(height: 16.0),
                  // Sources and Date display
                  if (uniqueSourceNames.isNotEmpty || displayDate != null)
                    Row(
                      children: [
                        if (uniqueSourceNames.isNotEmpty)
                          Expanded(
                            child: Text(
                              uniqueSourceNames.join(', '),
                              style: textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        if (uniqueSourceNames.isNotEmpty && displayDate != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                            ),
                            child: Text(
                              "•",
                              style: textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        // Changed format to remove time
                        if (displayDate != null)
                          Text(
                            DateFormat.yMMMd(
                              currentLocale.languageCode,
                            ).format(displayDate),
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  const SizedBox(height: 16.0),
                  // Summary or Content
                  if (!showFullContent)
                    Html(data: summaryToShow)
                  else
                    Html(data: contentToShow),
                  const SizedBox(height: 16.0),
                  // Read more / Show less button
                  if (summaryToShow.isNotEmpty && !showFullContent)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: TextButton(
                        onPressed: () {
                          ref.read(_showFullContentProvider.notifier).state =
                              true;
                        },
                        child: const Text("Read more..."),
                      ),
                    )
                  else if (showFullContent && contentToShow != summaryToShow)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: TextButton(
                        onPressed: () {
                          ref.read(_showFullContentProvider.notifier).state =
                              false;
                        },
                        child: const Text("Show less..."),
                      ),
                    ),
                ],
              ),
            );
          },
          loading: () => const Center(child: LoadingIndicator()),
          error:
              (err, stack) =>
                  Center(child: ErrorMessageWidget(message: err.toString())),
        ),
      ),
    );
  }
}
