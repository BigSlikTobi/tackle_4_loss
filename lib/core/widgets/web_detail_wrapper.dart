import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class WebDetailWrapper extends StatelessWidget {
  final Widget child;
  final double contentFlex;
  final double gutterFlex;
  final double maxContentWidth;
  final double mobileBreakpoint; // Added mobileBreakpoint

  const WebDetailWrapper({
    super.key,
    required this.child,
    this.contentFlex = 3.0,
    this.gutterFlex = 1.0,
    this.maxContentWidth = 960.0,
    this.mobileBreakpoint = 768.0, // Default mobile breakpoint
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (kIsWeb && screenWidth > mobileBreakpoint) {
      // Apply Row with Expanded for gutters and content (desktop/large tablet web)
      // Wrap the entire Row with a Scrollbar for web
      return Scrollbar(
        child: Row(
          children: [
            Expanded(
              flex: gutterFlex.round(),
              child: Container(), // Removed color
            ),
            Expanded(
              flex: contentFlex.round(),
              child: Container(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  // Wrap the child with ScrollConfiguration to hide its default scrollbar
                  // when the outer Scrollbar is active.
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(
                      context,
                    ).copyWith(scrollbars: false),
                    child:
                        child, // This 'child' is the SingleChildScrollView from the calling screen
                  ),
                ),
              ),
            ),
            Expanded(
              flex: gutterFlex.round(),
              child: Container(), // Removed color
            ),
          ],
        ),
      );
    } else {
      // Return child directly (for native mobile OR web on small screens)
      // For mobile, if the child itself is scrollable, it will have its own scrollbar.
      // If the whole page needs scrolling on mobile, the parent Scaffold/SingleChildScrollView should handle it.
      return child;
    }
  }
}
