// lib/core/providers/notification_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tackle_4_loss/core/services/notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  // NOTE: We do NOT call initialize here directly.
  // Initialization involves async operations and permissions UI
  // which shouldn't happen just by creating the service.
  return NotificationService();
});
