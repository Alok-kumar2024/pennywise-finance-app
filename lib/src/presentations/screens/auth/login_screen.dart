import 'package:animate_do/animate_do.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pennywise/src/core/provider/providers.dart';
import 'package:pennywise/src/core/utils/ui_helpers.dart';
import 'package:pennywise/src/presentations/providers/plaid_provider.dart';
import 'package:pennywise/src/presentations/providers/theme_provider.dart';
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

    setState(() {
      _isLoading = true;
    });

    try {
      final auth = ref.read(authRepositoryProvider);

      await auth.login(email, password);

      if (mounted) {
        UIHelpers.showSnackBar(context, message: "Welcome back!");
      }
    } catch (e) {
      final errorMsg = e.toString().contains('Exception: ')
          ? e.toString().split('Exception: ')[1]
          : "Invalid email or password";

      debugPrint("MESSAGE -> $errorMsg");

      UIHelpers.showSnackBar(context, message: errorMsg, isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final plaidState = ref.watch(plaidLinkProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHead(context),
              SizedBox(height: 30),
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
          SizedBox(height: 25),
          //Logo..
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.auto_graph),
          ),
          SizedBox(height: 24),

          //Text..
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
      padding: EdgeInsets.only(left: 5, right: 5, top: 10, bottom: 10),
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

            SizedBox(height: 20),

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

            SizedBox(height: 14),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {},
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

            SizedBox(height: 14),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: Size(double.infinity, 56),
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

            SizedBox(height: 40),

            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
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

            SizedBox(height: 24),

            OutlinedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: Size(double.infinity, 56),
              ),
              onPressed: () {
                UIHelpers.showSnackBar(
                  context,
                  message: "Google Sign-In coming soon!",
                );
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

            SizedBox(height: 35),
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
                      ..onTap = () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SignUpScreen()),
                        );
                      },
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
      padding: EdgeInsets.only(bottom: 8, left: 4),
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
