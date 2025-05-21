import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:tackle_4_loss/features/news_feed/data/cluster_article.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv

// Provider to track the current page index of the featured cluster PageView
final featuredClusterPageIndexProvider = StateProvider<int>((ref) => 0);

final featuredClusterProvider = FutureProvider<List<ClusterArticle>>((
  ref,
) async {
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseAnonKey == null) {
    if (kDebugMode) {
      print('Error: SUPABASE_ANON_KEY not found in .env file');
    }
    throw Exception(
      'SUPABASE_ANON_KEY not found. Ensure .env file is set up correctly.',
    );
  }

  final url = Uri.parse(
    'https://yqtiuzhedkfacwgormhn.supabase.co/functions/v1/cluster_articles',
  );
  if (kDebugMode) {
    print('[FeaturedClusterProvider] Fetching from URL: $url');
    // Avoid printing the key in production logs if possible, or ensure it's only in debug.
    // print('[FeaturedClusterProvider] Using Authorization: Bearer $supabaseAnonKey');
  }
  try {
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $supabaseAnonKey'},
    );

    if (kDebugMode) {
      print(
        '[FeaturedClusterProvider] Response Status Code: ${response.statusCode}',
      );
      // print('[FeaturedClusterProvider] Response Body: ${response.body}'); // Potentially very long
    }

    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);
      if (kDebugMode) {
        // print('[FeaturedClusterProvider] Decoded JSON response: $responseJson'); // Potentially very long
      }

      if (responseJson is Map<String, dynamic> &&
          responseJson.containsKey('data')) {
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
    } else {
      if (kDebugMode) {
        print(
          '[FeaturedClusterProvider] Failed to load featured cluster: ${response.statusCode} ${response.body}',
        );
      }
      throw Exception(
        'Failed to load featured cluster: ${response.statusCode}',
      );
    }
  } catch (e) {
    if (kDebugMode) {
      print('[FeaturedClusterProvider] Error fetching featured cluster: $e');
    }
    throw Exception('Error fetching or parsing featured cluster: $e');
  }
});
