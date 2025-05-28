// lib/features/news_feed/ui/widgets/other_news_list_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tackle_4_loss/features/news_feed/data/article_preview.dart';
import 'package:tackle_4_loss/core/providers/locale_provider.dart';
import 'package:tackle_4_loss/core/constants/team_constants.dart';
import 'package:tackle_4_loss/core/constants/source_constants.dart';

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

    String sourceDisplay;
    if (article.source != null &&
        sourceIdToDisplayName.containsKey(article.source)) {
      sourceDisplay = sourceIdToDisplayName[article.source!]!;
    } else if (article.source != null) {
      sourceDisplay = "Source ${article.source}";
    } else {
      sourceDisplay = "";
    }

    debugPrint(
      "[OtherNewsListItem build] Building for article ID: ${article.id}, Headline: $headlineToShow",
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 1.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          debugPrint("-----------------------------------------");
          debugPrint(
            "[OtherNewsListItem onTap CALLED!] Article ID: ${article.id}, Headline: $headlineToShow",
          );
          if (article.id == 0) {
            debugPrint(
              "[OtherNewsListItem onTap ERROR] Article ID is 0 or invalid. Cannot navigate.",
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Error: Article ID is invalid.")),
            );
            debugPrint("-----------------------------------------");
            return;
          }

          final String targetPath = '/article/${article.id}';
          final rootNavigatorContext =
              GoRouter.of(context).routerDelegate.navigatorKey.currentContext;
          final currentLocation =
              GoRouter.of(
                context,
              ).routeInformationProvider.value.uri.toString();

          debugPrint(
            "[OtherNewsListItem onTap PRE-PUSH] Current location: $currentLocation. Attempting to push '$targetPath' onto root navigator.",
          );

          try {
            if (rootNavigatorContext != null) {
              GoRouter.of(rootNavigatorContext).push(targetPath);
              debugPrint(
                "[OtherNewsListItem onTap POST-PUSH] Pushed '$targetPath' using rootNavigatorContext.",
              );
            } else {
              debugPrint(
                "[OtherNewsListItem onTap WARNING] Root navigator context is null. Falling back to standard context.push for '$targetPath'.",
              );
              GoRouter.of(context).push(targetPath);
              debugPrint(
                "[OtherNewsListItem onTap POST-PUSH] Pushed '$targetPath' using standard context (fallback).",
              );
            }

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                debugPrint(
                  "[OtherNewsListItem onTap POST-FRAME] GoRouter location after push: ${GoRouter.of(context).routeInformationProvider.value.uri.toString()}",
                );
              }
            });
          } catch (e, s) {
            debugPrint(
              "[OtherNewsListItem onTap ERROR ON PUSH] Failed to push for '$targetPath'. Error: $e",
            );
            debugPrint("Stacktrace: $s");
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Error navigating: $e")));
          }
          debugPrint("-----------------------------------------");
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                            height: 32,
                            width: 32,
                            fit: BoxFit.contain,
                            errorBuilder:
                                (ctx, err, st) =>
                                    const SizedBox(width: 32, height: 32),
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
