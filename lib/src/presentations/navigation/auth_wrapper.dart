import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pennywise/src/core/provider/providers.dart';
import 'package:pennywise/src/presentations/navigation/main_layout_screen.dart';
import 'package:pennywise/src/presentations/screens/auth/login_screen.dart';
import 'package:pennywise/src/presentations/screens/auth/plaid_connect_screen.dart';
import 'package:pennywise/src/presentations/screens/home/home_screen.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStateAsync = ref.watch(authStateProvider);

    return authStateAsync.when(
      loading: () => Scaffold(
        body: Center(
          child: SpinKitPulse(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      error: (err, stack) =>
          Scaffold(body: Center(child: Text("Error checking token"))),
      data: (isLoggedIn) {
        if (!isLoggedIn) {
          return const LoginScreen();
        }
        final hasPlaidTokenAsync = ref.watch(plaidTokenCheckProvider);

        return hasPlaidTokenAsync.when(
          loading: () => Scaffold(
            body: Center(
              child: SpinKitPulse(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          error: (err, stack) =>
              Scaffold(body: Center(child: Text("Error checking token"))),
          data: (hasPlaidToken) {
            if (hasPlaidToken) {
              return const MainLayoutScreen();
            } else {
              final hasSkippedAsync = ref.watch(plaidSkippedProvider);

              return hasSkippedAsync.when(
                loading: () => Scaffold(
                  body: Center(
                    child: SpinKitPulse(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                error: (err, stack) => const MainLayoutScreen(),
                data: (hasSkipped) {
                  if (hasSkipped) {
                    return const MainLayoutScreen();
                  } else {
                    return const PlaidConnectScreen();
                  }
                },
              );
            }
          },
        );
      },
    );
  }
}
