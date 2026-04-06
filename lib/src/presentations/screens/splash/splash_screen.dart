import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:pennywise/src/presentations/navigation/auth_wrapper.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Waits 3 seconds so the user can enjoy the animation
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        // Skips over to our Authentication logic!
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthWrapper()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(
        context,
      ).colorScheme.primary, // Dark premium color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ZoomIn(
              duration: const Duration(seconds: 1),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(
                    context,
                  ).colorScheme.onPrimary.withOpacity(0.2),
                ),
                child: Icon(
                  Icons.auto_graph,
                  size: 80,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            FadeInUp(
              delay: const Duration(milliseconds: 500),
              child: Text(
                "PennyWise",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
