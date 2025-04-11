import 'package:flutter/material.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Note: AppBar is now handled by the main navigation wrapper
      body: Center(
        child: Text(
          'Schedule - Coming Soon!',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
