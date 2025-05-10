// File: lib/features/cluster_detail/ui/widgets/cluster_summary_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tackle_4_loss/features/cluster_detail/data/cluster_summary_data.dart';
import 'package:tackle_4_loss/core/providers/locale_provider.dart';
import 'package:tackle_4_loss/core/widgets/loading_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

class ClusterSummaryWidget extends ConsumerWidget {
  final ClusterSummaryData summaryData;

  const ClusterSummaryWidget({super.key, required this.summaryData});

  Future<void> _launchUrl(Uri url, BuildContext context) async {
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
    final currentLocale = ref.watch(localeNotifierProvider);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final headline = summaryData.getLocalizedHeadline(
      currentLocale.languageCode,
    );
    final content = summaryData.getLocalizedContent(currentLocale.languageCode);
    final imageUrl = summaryData.imageUrl;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Headline
          Text(
            headline,
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 16.0),

          // Image
          if (imageUrl != null && imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        color: Colors.grey[200],
                        child: const Center(child: LoadingIndicator()),
                      ),
                    ),
                errorWidget:
                    (context, url, error) => AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: Colors.grey[500],
                          size: 48,
                        ),
                      ),
                    ),
              ),
            ),
          if (imageUrl != null && imageUrl.isNotEmpty)
            const SizedBox(height: 16.0),

          // Content (HTML)
          Html(
            data: content,
            style: {
              "body": Style(
                fontSize: FontSize(textTheme.bodyLarge?.fontSize ?? 16.0),
                color: textTheme.bodyLarge?.color,
                lineHeight: LineHeight(textTheme.bodyLarge?.height ?? 1.5),
                margin: Margins.zero, // Use Margins.zero for flutter_html Style
                padding: HtmlPaddings.zero, // Use HtmlPaddings.zero
              ),
              "p": Style(margin: Margins.only(bottom: 12.0)),
              "a": Style(
                color: theme.colorScheme.primary,
                textDecoration: TextDecoration.underline,
              ),
              // Add styles for other HTML elements if needed (h1, h2, ul, li, etc.)
            },
            onLinkTap: (url, attributes, element) {
              if (url != null) {
                final uri = Uri.tryParse(url);
                if (uri != null) {
                  _launchUrl(uri, context);
                } else {
                  debugPrint("Could not parse URL from HTML link: $url");
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
