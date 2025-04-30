import 'package:flutter/material.dart';
import 'package:tackle_4_loss/features/news_feed/data/mapped_cluster_story.dart';
import 'package:tackle_4_loss/features/news_feed/ui/widgets/cluster_story_view.dart';

class ClusterStoryDetailScreen extends StatefulWidget {
  final List<MappedClusterStory> stories;
  final int initialIndex;

  const ClusterStoryDetailScreen({
    super.key,
    required this.stories,
    required this.initialIndex,
  });

  @override
  ClusterStoryDetailScreenState createState() =>
      ClusterStoryDetailScreenState();
}

class ClusterStoryDetailScreenState extends State<ClusterStoryDetailScreen> {
  late final PageController _pageController;
  late int _currentIndex;
  double _scaleFactor = 1.0;

  @override
  void initState() {
    super.initState();
    debugPrint(
      'ClusterStoryDetailScreen init: initialIndex=${widget.initialIndex}',
    );
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    debugPrint('ClusterStoryDetailScreen page changed: index=$index');
    setState(() {
      _currentIndex = index;
      _scaleFactor = 1.0; // reset zoom on page change
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('ClusterStoryDetailScreen build: currentIndex=$_currentIndex');
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: widget.stories.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                final story = widget.stories[index];
                // Always apply hero tag for proper back animation
                final tag = 'story-${story.id}';
                // Wrap each page with pinch-to-dismiss gesture and scale effect
                return GestureDetector(
                  onScaleStart: (_) {
                    setState(() {});
                  },
                  onScaleUpdate: (details) {
                    final newScale = details.scale.clamp(0.5, 1.0);
                    setState(() {
                      _scaleFactor = newScale;
                    });
                  },
                  onScaleEnd: (_) {
                    setState(() {});
                    if (_scaleFactor < 0.8) {
                      Navigator.of(context).pop();
                    } else {
                      setState(() {
                        _scaleFactor = 1.0;
                      });
                    }
                  },
                  child: Transform.scale(
                    scale: index == _currentIndex ? _scaleFactor : 1.0,
                    child: ClusterStoryView(story: story, heroTag: tag),
                  ),
                );
              },
            ),
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
