import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pennywise/src/core/provider/providers.dart';

final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>(
      (ref) {
    final notifier = ThemeNotifier(ref);
    notifier.loadTheme(); // Automatically pulls their saved preference!
    return notifier;
  },
);

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final Ref ref;
  ThemeNotifier(this.ref) : super(ThemeMode.system);

  Future<void> loadTheme() async {
    final storage = ref.read(secureStorageProvider);
    final savedTheme = await storage.read(key: 'theme_mode');
    if (savedTheme == 'dark') {
      state = ThemeMode.dark;
    } else if (savedTheme == 'light') {
      state = ThemeMode.light;
    }
  }

  Future<void> toggleTheme() async {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    // Commits the aesthetic directly to Secure Storage!
    final storage = ref.read(secureStorageProvider);
    await storage.write(key: 'theme_mode', value: state == ThemeMode.dark ? 'dark' : 'light');
  }
}
