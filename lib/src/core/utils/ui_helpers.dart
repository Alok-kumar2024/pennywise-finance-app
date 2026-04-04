import 'package:flutter/material.dart';

class UIHelpers {
  static void showSnackBar(
    BuildContext context, {
    required String message,
    bool isError = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: isError
                ? colorScheme.onErrorContainer
                : colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: isError
            ? colorScheme.errorContainer
            : colorScheme.primaryContainer,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
