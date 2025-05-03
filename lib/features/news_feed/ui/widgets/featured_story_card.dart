import 'package:flutter/material.dart';
import 'package:tackle_4_loss/features/news_feed/data/mapped_cluster_story.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tackle_4_loss/core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- Simplified Widget ---
class FeaturedStoryCard extends ConsumerWidget {
  final MappedClusterStory story;
  // Optional: Add onTap callback if needed directly on the image part
  // final VoidCallback? onTap;

  const FeaturedStoryCard({
    super.key,
    required this.story,
    // this.onTap,
  });

  String? get _primaryImageUrl => story.primaryImageUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This widget now just returns the image part, possibly with gradient
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ClipRRect(
        // Use ClipRRect for rounded corners on the image itself
        borderRadius: BorderRadius.circular(16.0),
        child: Stack(
          // Stack for gradient overlay
          fit: StackFit.expand,
          children: [
            // Image
            (_primaryImageUrl != null && _primaryImageUrl!.isNotEmpty)
                ? CachedNetworkImage(
                  imageUrl: _primaryImageUrl!,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => Container(color: Colors.grey[300]),
                  errorWidget:
                      (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: Colors.grey[500],
                          size: 50,
                        ),
                      ),
                )
                : Container(
                  color: AppColors.primaryGreen,
                  child: Center(
                    child: Image.asset('assets/images/logo.jpg', width: 100),
                  ),
                ),

            // Optional Gradient (if desired on the image behind the text box)
            /* Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [ Colors.black.withOpacity(0.0), Colors.black.withOpacity(0.3)], // Lighter gradient
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),
              ), */
          ],
        ),
      ),
    );
  }
}
