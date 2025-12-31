import 'package:flutter/material.dart';

class NotificationService {
  static void showNotification(
    BuildContext context,
    String title,
    String message, {
    Color backgroundColor = const Color(0xFF2196F3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(message, style: const TextStyle(fontSize: 12)),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static void showStatusChangeNotification(
    BuildContext context,
    String newStatus,
  ) {
    showNotification(
      context,
      'Report Status Updated',
      'Your report status has changed to: $newStatus',
      backgroundColor: const Color(0xFF4CAF50),
    );
  }
}
