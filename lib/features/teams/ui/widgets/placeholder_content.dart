import 'package:flutter/material.dart';

class PlaceholderContent extends StatelessWidget {
  final String title;
  const PlaceholderContent({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          const Text('Coming Soon...'),
          const SizedBox(height: 20),
          const Icon(Icons.construction, size: 40, color: Colors.grey),
        ],
      ),
    );
  }
}
