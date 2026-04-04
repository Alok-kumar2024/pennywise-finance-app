import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pennywise/src/core/theme/app_theme.dart';
import 'package:pennywise/src/presentations/navigation/auth_wrapper.dart';
import 'package:pennywise/src/presentations/providers/theme_provider.dart';
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context,WidgetRef ref) {

    final themeMode = ref.watch(themeNotifierProvider);

    return MaterialApp(
      title: 'PennyWise',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: AuthWrapper(),
    );
  }
}

