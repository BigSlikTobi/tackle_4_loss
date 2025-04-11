import 'package:flutter/material.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Note: AppBar is now handled by the main navigation wrapper
      body: Center(
        child: Text(
          'More Screen - Coming Soon!',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
