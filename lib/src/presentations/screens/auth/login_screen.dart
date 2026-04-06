import 'package:animate_do/animate_do.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pennywise/src/core/provider/providers.dart';
import 'package:pennywise/src/core/utils/ui_helpers.dart';
import 'package:pennywise/src/presentations/providers/plaid_provider.dart';
import 'package:pennywise/src/presentations/screens/auth/signup_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginScreen();
}

class _LoginScreen extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _showForgotPasswordSheet(BuildContext context) {
    final emailController = TextEditingController(text: _emailController.text);
    bool sheetLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
            ),
            padding: EdgeInsets.only(
              top: 32,
              left: 24,
              right: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Reset Password",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Enter your account email. We will send you a secure link to generate a brand new password.",
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: "Email address",
                    filled: true,
                    fillColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: sheetLoading
                      ? null
                      : () async {
                          if (emailController.text.isEmpty) return;
                          setSheetState(() => sheetLoading = true);
                          try {
                            await ref
                                .read(authRepositoryProvider)
                                .resetPasswordForEmail(emailController.text);
                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                              UIHelpers.showSnackBar(
                                context,
                                message:
                                    "Reset link heavily-secured and sent to ${emailController.text}",
                              );
                            }
                          } catch (e) {
                            if (ctx.mounted)
                              UIHelpers.showSnackBar(
                                context,
                                message: "Error sending reset link.",
                                isError: true,
                              );
                          } finally {
                            setSheetState(() => sheetLoading = false);
                          }
                        },
                  child: sheetLoading
                      ? const SpinKitPulse(color: Colors.white, size: 24)
                      : const Text(
                          "SEND RESET LINK",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      UIHelpers.showSnackBar(
        context,
        message: "Please enter both email and password",
        isError: true,
      );
      return;
    }

    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    );
    if (!emailRegex.hasMatch(email)) {
      UIHelpers.showSnackBar(
        context,
        message: "Please enter a valid email address.",
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).login(email, password);
      if (mounted) UIHelpers.showSnackBar(context, message: "Welcome back!");
    } catch (e) {
      final errorMsg = e.toString().contains('Exception: ')
          ? e.toString().split('Exception: ')[1]
          : "Invalid email or password";
      UIHelpers.showSnackBar(context, message: errorMsg, isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(plaidLinkProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHead(context),
              const SizedBox(height: 30),
              _buildBody(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHead(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 25),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.auto_graph),
          ),
          const SizedBox(height: 24),
          FadeInDown(
            duration: const Duration(milliseconds: 400),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Welcome back\n",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  TextSpan(
                    text: "Sign in to your account",
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.5),
                      fontSize: 18,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5, top: 10, bottom: 10),
      child: FadeInUp(
        duration: const Duration(milliseconds: 400),
        child: Column(
          children: [
            _buildLabel(context, "EMAIL"),
            TextField(
              controller: _emailController,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: "xyz@gmail.com",
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildLabel(context, "PASSWORD"),
            TextField(
              controller: _passwordController,
              obscureText: true,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: "Enter password",
                prefixIcon: Icon(
                  Icons.lock_outline,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _showForgotPasswordSheet(context),
                  child: Text(
                    "Forgot password?",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withOpacity(0.8),
              ),
              onPressed: _isLoading ? null : _handleLogin,
              child: _isLoading
                  ? SpinKitRing(
                      color: Theme.of(context).colorScheme.onSurface,
                      size: 35,
                      lineWidth: 3,
                    )
                  : Text(
                      "LOGIN",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "OR",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.color?.withOpacity(0.5),
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 56),
              ),
              onPressed: () async {
                try {
                  await ref.read(authRepositoryProvider).signInWithGoogle();
                } catch (e) {
                  if (context.mounted) {
                    UIHelpers.showSnackBar(
                      context,
                      message: "Error launching Google: $e",
                      isError: true,
                    );
                  }
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(
                    Icons.g_mobiledata_sharp,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  Text(
                    "Continue with Google",
                    style: TextStyle(
                      color: Theme.of(context).textTheme.displayLarge?.color,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 35),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Don't have an account?",
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 18,
                      letterSpacing: 0.1,
                    ),
                  ),
                  TextSpan(
                    text: "  Sign up",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 18,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignUpScreen()),
                      ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(
            color: Theme.of(
              context,
            ).textTheme.bodyLarge?.color?.withOpacity(0.7),
            fontSize: 11,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
