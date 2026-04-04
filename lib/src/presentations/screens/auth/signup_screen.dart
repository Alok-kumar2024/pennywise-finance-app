import 'package:animate_do/animate_do.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pennywise/src/core/provider/providers.dart';
import 'package:pennywise/src/core/utils/ui_helpers.dart';
import 'package:pennywise/src/presentations/providers/plaid_provider.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignUpScreen();
}

class _SignUpScreen extends ConsumerState<SignUpScreen> {
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isAgree = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleSignUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty ||
        password.isEmpty ||
        name.isEmpty ||
        confirmPassword.isEmpty) {
      UIHelpers.showSnackBar(
        context,
        message: "Please enter all Fields",
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

    if (password != confirmPassword) {
      UIHelpers.showSnackBar(
        context,
        message: "Password not matched.",
        isError: true,
      );

      return;
    }

    if (!_isAgree) {
      UIHelpers.showSnackBar(
        context,
        message: "Please agree to the policy.",
        isError: true,
      );

      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final auth = ref.read(authRepositoryProvider);

      await auth.signup(email, password);

      if (mounted) {
        UIHelpers.showSnackBar(
          context,
          message: "Account created successfully!",
        );
        Navigator.pop(context);
      }
    } catch (e) {
      final errorMsg = e.toString().contains('Exception: ')
          ? e.toString().split('Exception: ')[1]
          : "Error creating account";
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
            _buildLabel(context, "FULL NAME"),
            TextField(
              controller: _nameController,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: "john doe",
                prefixIcon: Icon(
                  Icons.person_2_outlined,
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

            SizedBox(height: 20),

            _buildLabel(context, "CONFIRM PASSWORD"),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: "confirm password",
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
                Checkbox(
                  value: _isAgree,
                  activeColor: Theme.of(context).colorScheme.primary,
                  onChanged: (val) => setState(() => _isAgree = val!),
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: "I agree to the",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      children: [
                        TextSpan(
                          text: "Terms and Privacy Policy",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
                ).colorScheme.primary.withOpacity(0.9),
              ),
              onPressed: _isLoading ? null : _handleSignUp,
              child: _isLoading
                  ? SpinKitRing(
                      color: Theme.of(context).colorScheme.onSurface,
                      size: 35,
                      lineWidth: 3,
                    )
                  : Text(
                      "SIGN UP",
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
                    text: "Already a member?",
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 18,
                      letterSpacing: 0.1,
                    ),
                  ),
                  TextSpan(
                    text: "  Sign in",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 18,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.pop(context);
                      },
                  ),
                ],
              ),
            ),
            SizedBox(height: 35),
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
