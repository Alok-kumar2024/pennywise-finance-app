import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pennywise/src/core/utils/ui_helpers.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _updatePassword() async {
    if (_passwordController.text.length < 6) {
      UIHelpers.showSnackBar(context, message: 'Password must be at least 6 characters', isError: true);
      return;
    }
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: _passwordController.text),
      );
      if (mounted) {
        UIHelpers.showSnackBar(context, message: 'Password successfully updated!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) UIHelpers.showSnackBar(context, message: e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: const Text('Change Password'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Enter new password',
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: _isLoading ? null : _updatePassword,
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('UPDATE SECURELY'),
            )
          ],
        ),
      ),
    );
  }
}
