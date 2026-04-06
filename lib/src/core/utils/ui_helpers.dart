import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

class UIHelpers {
  static void showSnackBar(
    BuildContext context, {
    required String message,
    bool isError = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final overlay = Overlay.of(context);

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        // Dynamically detects the exact height of the phone's notch/status bar!
        top: MediaQuery.of(context).padding.top + 16,
        left: 24,
        right: 24,
        child: Material(
          color: Colors.transparent,
          child: FadeInDown(
            duration: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: isError
                    ? colorScheme.errorContainer
                    : colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isError
                      ? colorScheme.onErrorContainer
                      : colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // Slide it onto the screen!
    overlay.insert(overlayEntry);

    // Smoothly destroy it after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  static IconData getCategoryIcon(String category) {
    category = category.toLowerCase();
    if (category.contains('food') || category.contains('dining'))
      return Icons.fastfood;
    if (category.contains('grocer')) return Icons.shopping_cart;
    if (category.contains('transport') || category.contains('travel'))
      return Icons.directions_car;
    if (category.contains('utilit')) return Icons.electric_bolt;
    if (category.contains('shop')) return Icons.shopping_bag;
    if (category.contains('salary') ||
        category.contains('freelance') ||
        category.contains('payment'))
      return Icons.payments;
    if (category.contains('gift')) return Icons.card_giftcard;
    if (category.contains('invest')) return Icons.trending_up;
    if (category.contains('transfer')) return Icons.sync_alt;
    if (category.contains('recreation')) return Icons.sports_esports;
    return Icons.receipt_long; // default
  }

  static Color getCategoryColor(String category) {
    category = category.toLowerCase();
    if (category.contains('food') || category.contains('dining'))
      return Colors.orange;
    if (category.contains('grocer')) return Colors.green;
    if (category.contains('transport') || category.contains('travel'))
      return Colors.blue;
    if (category.contains('utilit')) return Colors.yellow.shade700;
    if (category.contains('shop')) return Colors.purple;
    if (category.contains('salary') ||
        category.contains('freelance') ||
        category.contains('payment'))
      return Colors.teal;
    if (category.contains('gift')) return Colors.pink;
    if (category.contains('invest')) return Colors.indigo;
    if (category.contains('transfer')) return Colors.cyan;
    return Colors.grey; // default
  }

  static String formatCompactNumber(double number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toStringAsFixed(2);
    }
  }

  static String formatCompactCurrency(double value, {bool signed = false}) {
    final abs = value.abs();
    String core;
    if (abs >= 1e9) {
      core = '${(abs / 1e9).toStringAsFixed(abs >= 1e10 ? 0 : 1)}B';
    } else if (abs >= 1e6) {
      core = '${(abs / 1e6).toStringAsFixed(abs >= 1e7 ? 0 : 1)}M';
    } else if (abs >= 1e3) {
      core = '${(abs / 1e3).toStringAsFixed(abs >= 1e4 ? 0 : 1)}K';
    } else {
      core = abs.toStringAsFixed(abs >= 100 ? 0 : 2);
    }
    final body = '\$$core';
    if (!signed) return body;
    if (value > 0) return '+$body';
    if (value < 0) return '-$body';
    return body;
  }
}
