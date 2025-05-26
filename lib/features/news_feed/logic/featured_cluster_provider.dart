import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tackle_4_loss/features/news_feed/data/cluster_article.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Provider to track the current page index of the featured cluster PageView
final featuredClusterPageIndexProvider = StateProvider<int>((ref) => 0);

final featuredClusterProvider = FutureProvider<List<ClusterArticle>>((
  ref,
) async {
  final supabaseClient = Supabase.instance.client;

  if (kDebugMode) {
    print(
      '[FeaturedClusterProvider] Fetching featured cluster data using Supabase client',
    );
  }

  try {
    final response = await supabaseClient.functions.invoke(
      'cluster_articles',
      method: HttpMethod.get,
    );

    if (kDebugMode) {
      print('[FeaturedClusterProvider] Response Status: ${response.status}');
    }

    if (response.status != 200) {
      var errorData = response.data;
      String errorMessage =
          'Failed to load featured cluster: Status code ${response.status}';
      if (errorData is Map && errorData.containsKey('error')) {
        errorMessage += ': ${errorData['error']}';
        if (errorData.containsKey('details')) {
          errorMessage += '. Details: ${errorData['details']}';
        }
      }
      if (kDebugMode) {
        print('[FeaturedClusterProvider] Error response: $errorData');
      }
      throw Exception(errorMessage);
    }

    if (response.data == null) {
      throw Exception('Failed to load featured cluster: Received null data');
    }

    final responseJson = response.data as Map<String, dynamic>;
    if (kDebugMode) {
      print('[FeaturedClusterProvider] Successfully received response data');
    }

    if (responseJson.containsKey('data')) {
      final dataList = responseJson['data'];
      if (dataList is List) {
        // Allow empty list
        // Map each item in the list to a ClusterArticle
        final articles =
            dataList
                .map((item) {
                  if (item is Map<String, dynamic>) {
                    return ClusterArticle.fromJson(item);
                  } else {
                    // Log or handle items that are not maps, if necessary
                    if (kDebugMode) {
                      print(
                        '[FeaturedClusterProvider] Item in dataList is not a Map: $item',
                      );
                    }
                    return null; // Or throw an error
                  }
                })
                .whereType<ClusterArticle>()
                .toList(); // Filter out nulls and ensure correct type

        // Sort articles by displayDate (newest source date or article.createdAt)
        articles.sort((a, b) {
          DateTime? dateA;
          if (a.sources.isNotEmpty) {
            final validDatesA =
                a.sources
                    .map((source) => source.createdAt)
                    .whereType<DateTime>()
                    .toList();
            if (validDatesA.isNotEmpty) {
              validDatesA.sort((x, y) => y.compareTo(x));
              dateA = validDatesA.first;
            }
          }
          dateA ??= a.createdAt;

          DateTime? dateB;
          if (b.sources.isNotEmpty) {
            final validDatesB =
                b.sources
                    .map((source) => source.createdAt)
                    .whereType<DateTime>()
                    .toList();
            if (validDatesB.isNotEmpty) {
              validDatesB.sort((x, y) => y.compareTo(x));
              dateB = validDatesB.first;
            }
          }
          dateB ??= b.createdAt;

          if (dateA == null && dateB == null) return 0;
          if (dateA == null) return 1; // Treat nulls as older
          if (dateB == null) return -1; // Treat nulls as older
          return dateB.compareTo(dateA); // Sort descending
        });

        if (kDebugMode) {
          print(
            '[FeaturedClusterProvider] Parsed and sorted ${articles.length} ClusterArticles.',
          );
          if (articles.isNotEmpty) {
            final firstArticle = articles.first;
            print('  First Article ID: ${firstArticle.clusterArticleId}');
            print(
              '  First Article English Headline: ${firstArticle.englishHeadline.substring(0, (firstArticle.englishHeadline.length > 50) ? 50 : firstArticle.englishHeadline.length)}...',
            ); // Log snippet
          }
        }
        return articles;
      } else {
        throw Exception('"data" field is not a list.');
      }
    } else {
      throw Exception(
        'Unexpected API response structure: Missing "data" key or not a Map.',
      );
    }
  } on FunctionException catch (e) {
    if (kDebugMode) {
      print(
        '[FeaturedClusterProvider] Supabase FunctionException: ${e.details}',
      );
    }
    throw Exception(
      'Error invoking cluster_articles function: ${e.details ?? e.toString()}',
    );
  } catch (e) {
    if (kDebugMode) {
      print('[FeaturedClusterProvider] Error fetching featured cluster: $e');
    }
    throw Exception('Error fetching or parsing featured cluster: $e');
  }
});
