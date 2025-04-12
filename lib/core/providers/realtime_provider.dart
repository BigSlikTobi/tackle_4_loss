import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tackle_4_loss/core/services/realtime_service.dart';

final realtimeServiceProvider = Provider<RealtimeService>((ref) {
  final service = RealtimeService(ref);
  // Initialize listeners when the provider is first created/read.
  service.initializeListeners();

  // Ensure the service is disposed when the provider is disposed.
  ref.onDispose(() => service.dispose());

  return service;
});
