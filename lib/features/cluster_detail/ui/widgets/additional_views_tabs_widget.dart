// lib/features/cluster_detail/ui/widgets/additional_views_tabs_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tackle_4_loss/features/cluster_detail/logic/cluster_detail_provider.dart';
import 'package:tackle_4_loss/features/cluster_detail/data/single_view_data.dart';
import 'package:tackle_4_loss/core/widgets/loading_indicator.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:tackle_4_loss/core/providers/locale_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AdditionalViewsTabsWidget extends ConsumerWidget {
  final String clusterId;

  const AdditionalViewsTabsWidget({super.key, required this.clusterId});

  Widget _buildTab(
    BuildContext context,
    IconData iconData,
    String label,
    AdditionalViewType type,
    WidgetRef ref,
  ) {
    return Expanded(
      child: InkWell(
        onTap: () {
          final selectedNotifier = ref.read(
            selectedAdditionalViewProvider.notifier,
          );
          final currentType = ref.read(selectedAdditionalViewProvider);

          debugPrint(
            "[AdditionalViewsTabsWidget._buildTab] Tapped tab: $label (type: $type). Current selected type: $currentType",
          );

          if (currentType != type) {
            selectedNotifier.state = type;
            debugPrint(
              "[AdditionalViewsTabsWidget._buildTab] Changed selectedAdditionalViewProvider to: $type",
            );
          }
          _showViewContentSheet(context, ref, type, clusterId);
        },
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                iconData,
                size: 26,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontSize: 10),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showViewContentSheet(
    BuildContext context,
    WidgetRef ref,
    AdditionalViewType viewType,
    String clusterId,
  ) {
    debugPrint(
      "[_showViewContentSheet] Attempting to show sheet for viewType: $viewType, clusterId: $clusterId",
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) {
            return Consumer(
              builder: (context, consumerRef, child) {
                final asyncData = consumerRef.watch(
                  currentViewDataProvider(clusterId),
                );
                final currentSelectedTabType = consumerRef.read(
                  selectedAdditionalViewProvider,
                );

                debugPrint(
                  "[_showViewContentSheet Draggable.builder] Rebuilding sheet content. Selected tab type: $currentSelectedTabType. AsyncData state for currentViewDataProvider: $asyncData",
                );

                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(sheetContext).cardColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(38),
                        blurRadius: 10.0,
                        spreadRadius: 2.0,
                      ),
                    ],
                  ),
                  child: asyncData.when(
                    data: (viewData) {
                      debugPrint(
                        "[_showViewContentSheet Draggable.builder data] Received viewData: ${viewData != null ? 'Instance of SingleViewData for view: ${viewData.viewName}' : 'null'}",
                      );
                      if (viewData == null) {
                        String msg = "Content for this view is not available.";
                        if (currentSelectedTabType ==
                                AdditionalViewType.dynamic1 ||
                            currentSelectedTabType ==
                                AdditionalViewType.dynamic2) {
                          final dynamicState = consumerRef.read(
                            dynamicViewsProvider(clusterId),
                          );
                          dynamicState.whenData((dynamicResponseData) {
                            final viewsAvailable =
                                dynamicResponseData.availableViews;
                            debugPrint(
                              "Dynamic views available from backend: $viewsAvailable. Current tab: $currentSelectedTabType",
                            );
                            if (dynamicResponseData.views.isEmpty ||
                                (currentSelectedTabType ==
                                        AdditionalViewType.dynamic2 &&
                                    dynamicResponseData.views.length < 2)) {
                              msg =
                                  "This dynamic view ('${currentSelectedTabType == AdditionalViewType.dynamic1
                                      ? viewsAvailable.isNotEmpty
                                          ? viewsAvailable[0]
                                          : 'Dynamic 1'
                                      : viewsAvailable.length > 1
                                      ? viewsAvailable[1]
                                      : 'Dynamic 2'}') is not available for this story.";
                            }
                          });
                        }
                        debugPrint(
                          "[_showViewContentSheet Draggable.builder data] viewData is null. Displaying message: '$msg'",
                        );
                        return _buildEmptyOrErrorContent(
                          scrollController,
                          msg,
                          null,
                          sheetContext,
                        );
                      }
                      return ViewContentSheet(
                        viewData: viewData,
                        scrollController: scrollController,
                      );
                    },
                    loading: () {
                      debugPrint(
                        "[_showViewContentSheet Draggable.builder loading] currentViewDataProvider is loading for clusterId: $clusterId, viewType: $currentSelectedTabType",
                      );
                      return _buildLoadingContent(
                        scrollController,
                        sheetContext,
                      );
                    },
                    error: (error, stackTrace) {
                      debugPrint(
                        "[_showViewContentSheet Draggable.builder error] Error loading view for $currentSelectedTabType: $error\n$stackTrace",
                      );
                      return _buildEmptyOrErrorContent(
                        scrollController,
                        "Error loading view: ${error.toString().split(':').first.trim()}",
                        () {
                          Navigator.pop(sheetContext);
                          switch (viewType) {
                            case AdditionalViewType.coach:
                              consumerRef.invalidate(
                                coachViewProvider(clusterId),
                              );
                              break;
                            case AdditionalViewType.player:
                              consumerRef.invalidate(
                                playerViewProvider(clusterId),
                              );
                              break;
                            case AdditionalViewType.franchise:
                              consumerRef.invalidate(
                                franchiseViewProvider(clusterId),
                              );
                              break;
                            case AdditionalViewType.team:
                              consumerRef.invalidate(
                                teamViewProvider(clusterId),
                              );
                              break;
                            case AdditionalViewType.dynamic1:
                            case AdditionalViewType.dynamic2:
                              consumerRef.invalidate(
                                dynamicViewsProvider(clusterId),
                              );
                              break;
                            case AdditionalViewType.none:
                              break;
                          }
                        },
                        sheetContext,
                      );
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingContent(
    ScrollController scrollController,
    BuildContext context,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Center(
            child: Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(bottom: 12.0),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const Expanded(child: Center(child: LoadingIndicator())),
      ],
    );
  }

  Widget _buildEmptyOrErrorContent(
    ScrollController scrollController,
    String message,
    VoidCallback? onRetry,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(bottom: 20.0),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(100, 40)),
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dynamicViewsState = ref.watch(dynamicViewsProvider(clusterId));

    bool showDynamic1 = false;
    bool showDynamic2 = false;
    String dynamic1Label = "Dynamic"; // Default label
    String dynamic2Label = "Insight"; // Default label

    // Correctly use .whenData to access the data part of AsyncValue
    dynamicViewsState.whenData((data) {
      final available = data.availableViews;
      if (available.isNotEmpty) {
        showDynamic1 = true;
        dynamic1Label = available[0];
        debugPrint(
          "[AdditionalViewsTabsWidget.build] Dynamic Tab 1 Label set to: $dynamic1Label",
        );
      }
      if (available.length > 1) {
        showDynamic2 = true;
        dynamic2Label = available[1];
        debugPrint(
          "[AdditionalViewsTabsWidget.build] Dynamic Tab 2 Label set to: $dynamic2Label",
        );
      }
    });
    // Logging for error or loading states of dynamicViewsState can be done by checking its properties
    if (dynamicViewsState.hasError) {
      debugPrint(
        "[AdditionalViewsTabsWidget.build] Error loading dynamicViewsProvider: ${dynamicViewsState.error}. Dynamic tabs might not show or show default labels.",
      );
    }
    if (dynamicViewsState.isLoading) {
      debugPrint(
        "[AdditionalViewsTabsWidget.build] dynamicViewsProvider is loading. Dynamic tabs will use placeholders if shown.",
      );
    }

    bool dynamicTabsPlaceholders =
        dynamicViewsState.isLoading || dynamicViewsState.hasError;

    int fixedTabCount = 4;
    int dynamicTabCount = 0;
    if (showDynamic1 || dynamicTabsPlaceholders) dynamicTabCount++;
    if (showDynamic2 || (dynamicTabsPlaceholders && dynamicTabCount == 1)) {
      dynamicTabCount++;
    }

    int totalVisibleTabs = fixedTabCount + dynamicTabCount;
    int maxTabs = 6;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 0.8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildTab(
            context,
            Icons.mic_external_on_outlined,
            'Coach',
            AdditionalViewType.coach,
            ref,
          ),
          _buildTab(
            context,
            Icons.person_outline,
            'Player',
            AdditionalViewType.player,
            ref,
          ),
          _buildTab(
            context,
            Icons.business_outlined,
            'Franchise',
            AdditionalViewType.franchise,
            ref,
          ),
          _buildTab(
            context,
            Icons.shield_outlined,
            'Team',
            AdditionalViewType.team,
            ref,
          ),

          if (showDynamic1 ||
              (dynamicTabsPlaceholders && totalVisibleTabs < maxTabs))
            _buildTab(
              context,
              Icons.insights_outlined,
              dynamic1Label,
              AdditionalViewType.dynamic1,
              ref,
            ),

          if (showDynamic2 ||
              (dynamicTabsPlaceholders &&
                  totalVisibleTabs < maxTabs &&
                  (showDynamic1 ||
                      (dynamicTabsPlaceholders && dynamicTabCount >= 1))))
            _buildTab(
              context,
              Icons.auto_awesome_outlined,
              dynamic2Label,
              AdditionalViewType.dynamic2,
              ref,
            ),

          if (totalVisibleTabs < maxTabs)
            for (int i = 0; i < (maxTabs - totalVisibleTabs); i++)
              const Expanded(child: SizedBox()),
        ],
      ),
    );
  }
}

class ViewContentSheet extends ConsumerWidget {
  final SingleViewData viewData;
  final ScrollController scrollController;

  const ViewContentSheet({
    super.key,
    required this.viewData,
    required this.scrollController,
  });

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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final currentLocale = ref.watch(localeNotifierProvider);

    debugPrint(
      "[ViewContentSheet.build] Current locale from provider: ${currentLocale.languageCode} for view: ${viewData.viewName}",
    );

    final headline = viewData.getLocalizedHeadline(currentLocale.languageCode);
    final content = viewData.getLocalizedContent(currentLocale.languageCode);

    debugPrint(
      "[ViewContentSheet.build] Displaying view: '${viewData.viewName}' with localized data:\n"
      "  Headline: '$headline'\n"
      "  Content (first 50): '${content.substring(0, content.length > 50 ? 50 : content.length)}...'",
    );

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 20.0),
      children: <Widget>[
        Center(
          child: Container(
            width: 40,
            height: 5,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        if (viewData.viewName != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              viewData.specificIdentifier != null
                  ? "${viewData.viewName}: ${viewData.specificIdentifier}"
                  : viewData.viewName!,
              style: textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        Text(
          headline,
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 10),
        Html(
          data: content,
          style: {
            "body": Style(
              fontSize: FontSize(textTheme.bodyMedium?.fontSize ?? 15.0),
              color: textTheme.bodyMedium?.color,
              lineHeight: LineHeight(textTheme.bodyMedium?.height ?? 1.4),
              margin: Margins.zero,
              padding: HtmlPaddings.zero,
            ),
            "p": Style(margin: Margins.only(bottom: 10.0)),
            "a": Style(
              color: theme.colorScheme.primary,
              textDecoration: TextDecoration.underline,
            ),
          },
          onLinkTap: (url, attributes, element) {
            if (url != null) {
              final uri = Uri.tryParse(url);
              if (uri != null) {
                _launchUrl(uri, context);
              }
            }
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
