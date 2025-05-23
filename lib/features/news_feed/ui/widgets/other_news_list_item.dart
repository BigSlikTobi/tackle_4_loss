import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tackle_4_loss/features/news_feed/data/article_preview.dart';
import 'package:tackle_4_loss/core/providers/locale_provider.dart';
import 'package:tackle_4_loss/core/providers/navigation_provider.dart';
import 'package:tackle_4_loss/core/constants/team_constants.dart';
import 'package:tackle_4_loss/core/constants/source_constants.dart'; // Ensure this is imported

class OtherNewsListItem extends ConsumerWidget {
  final ArticlePreview article;

  const OtherNewsListItem({super.key, required this.article});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final currentLocale = ref.watch(localeNotifierProvider);

    final headlineToShow =
        (currentLocale.languageCode == 'de' &&
                article.germanHeadline.isNotEmpty)
            ? article.germanHeadline
            : (article.englishHeadline.isNotEmpty
                ? article.englishHeadline
                : "No Title");

    // --- CORRECTED Source Name Logic ---
    String sourceDisplay;
    if (article.source != null &&
        sourceIdToDisplayName.containsKey(article.source)) {
      sourceDisplay = sourceIdToDisplayName[article.source!]!;
    } else if (article.source != null) {
      // Fallback if ID exists but not in map: show "Source X"
      sourceDisplay = "Source ${article.source}";
    } else {
      // Fallback if source field is null
      sourceDisplay = "";
    }
    // --- END CORRECTION ---

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 1.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      clipBehavior: Clip.antiAlias, // Ensures InkWell splash is clipped
      child: InkWell(
        onTap: () {
          debugPrint(
            "Tapped Other News Item ${article.id}. Navigating to detail.",
          );
          ref.read(currentDetailArticleIdProvider.notifier).state = article.id;
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Increased internal padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                headlineToShow,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      // Use the resolved sourceDisplay
                      "$sourceDisplay${article.createdAt != null ? " • ${DateFormat.yMd(currentLocale.languageCode).format(article.createdAt!.toLocal())}" : ""}",
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (article.teamId != null && article.teamId!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Container(
                        padding: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: theme.scaffoldBackgroundColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 0.5,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            getTeamLogoPath(article.teamId!),
                            height: 32, // Changed from 18 to 32
                            width: 32, // Changed from 18 to 32
                            fit: BoxFit.contain,
                            errorBuilder:
                                (ctx, err, st) => const SizedBox(
                                  width: 54,
                                  height: 54,
                                ), // Changed from 18 to 54
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
