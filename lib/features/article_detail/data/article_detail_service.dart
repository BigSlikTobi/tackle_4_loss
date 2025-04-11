// lib/features/article_detail/data/article_detail_service.dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tackle_4_loss/features/article_detail/data/article_detail.dart';

class ArticleDetailService {
  final SupabaseClient _supabaseClient;

  ArticleDetailService({SupabaseClient? supabaseClient})
    : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  Future<ArticleDetail> getArticleDetail(int articleId) async {
    try {
      final functionName = 'articleDetail';
      final parameters = {
        'id': articleId.toString(), // Pass articleId as query parameter
      };

      debugPrint("Fetching article detail for ID: $articleId");

      final response = await _supabaseClient.functions.invoke(
        functionName,
        method: HttpMethod.get, // Assuming GET method
        queryParameters: parameters,
      );

      if (response.status != 200) {
        var errorData = response.data;
        String errorMessage = 'Status code ${response.status}';
        if (errorData is Map && errorData.containsKey('error')) {
          errorMessage += ': ${errorData['error']}';
        } else if (errorData != null) {
          errorMessage += ': ${errorData.toString().substring(0, 100)}...';
        }
        debugPrint('Error response data: $errorData');
        throw Exception('Failed to load article detail: $errorMessage');
      }

      if (response.data == null) {
        throw Exception(
          'Failed to load article detail: Received null data from function.',
        );
      }

      final responseData = response.data as Map<String, dynamic>;

      // Check if the function itself returned an error structure
      if (responseData.containsKey('error')) {
        throw Exception('Error from Edge Function: ${responseData['error']}');
      }
      // Optionally check if the expected data field exists if your function wraps data
      // final articleData = responseData['data'] as Map<String, dynamic>? ?? responseData;

      final article = ArticleDetail.fromJson(
        responseData,
      ); // Use responseData directly if not wrapped
      debugPrint("Successfully fetched article detail for ID: $articleId");
      return article;
    } on FunctionException catch (e) {
      debugPrint('Supabase FunctionException Details: ${e.details}');
      debugPrint('Supabase FunctionException toString(): ${e.toString()}');
      final errorMessage = e.details?.toString() ?? e.toString();
      throw Exception('Error fetching article detail: $errorMessage');
    } catch (e, stacktrace) {
      debugPrint('Generic error fetching article detail: $e');
      debugPrint('Stacktrace: $stacktrace');
      throw Exception('An unexpected error occurred fetching the article.');
    }
  }
}
