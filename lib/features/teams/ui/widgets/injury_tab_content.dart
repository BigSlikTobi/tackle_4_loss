import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tackle_4_loss/core/widgets/loading_indicator.dart';
import 'package:tackle_4_loss/core/widgets/error_message.dart';
import 'package:tackle_4_loss/features/teams/logic/injury_provider.dart'; // Import injury provider
import 'package:tackle_4_loss/features/teams/ui/widgets/injury_list_item.dart'; // Import list item widget

class InjuryTabContent extends ConsumerStatefulWidget {
  final String teamAbbreviation;

  const InjuryTabContent({super.key, required this.teamAbbreviation});

  @override
  ConsumerState<InjuryTabContent> createState() => _InjuryTabContentState();
}

class _InjuryTabContentState extends ConsumerState<InjuryTabContent> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref
          .read(injuryProvider(widget.teamAbbreviation).notifier)
          .fetchNextPage();
    }
  }

  Future<void> _handleRefresh() async {
    ref.invalidate(injuryProvider(widget.teamAbbreviation));
    // Optional: await future if needed
  }

  @override
  Widget build(BuildContext context) {
    final injuryAsyncValue = ref.watch(injuryProvider(widget.teamAbbreviation));

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: injuryAsyncValue.when(
        data: (injuryState) {
          final injuries = injuryState.injuries;

          if (injuries.isEmpty &&
              !injuryState.hasMore &&
              !injuryAsyncValue.isLoading) {
            // Check hasMore and isLoading
            return LayoutBuilder(
              // Allow refresh on empty
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: const Center(child: Text("No injury data found.")),
                  ),
                );
              },
            );
          }

          return ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount:
                injuries.length + (injuryState.isLoadingNextPage ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == injuries.length && injuryState.isLoadingNextPage) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: LoadingIndicator(),
                );
              }
              if (index < injuries.length) {
                return InjuryListItem(injury: injuries[index]);
              }
              return Container();
            },
          );
        },
        loading: () => const LoadingIndicator(),
        error:
            (error, stackTrace) => LayoutBuilder(
              // Allow refresh on error
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ErrorMessageWidget(
                          message:
                              'Failed to load injuries: ${error.toString()}',
                          onRetry:
                              () => ref.invalidate(
                                injuryProvider(widget.teamAbbreviation),
                              ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      ),
    );
  }
}
