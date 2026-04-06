import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pennywise/src/core/provider/providers.dart';
import 'package:pennywise/src/core/utils/ui_helpers.dart';
import 'package:pennywise/src/presentations/providers/theme_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pennywise/src/presentations/screens/auth/plaid_connect_screen.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  void _showChangePasswordSheet(BuildContext context, WidgetRef ref) {
    final oldTc = TextEditingController();
    final newTc = TextEditingController();
    bool isLoading = false;

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
                  "Update Secure Password",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Please verify your identity to change the vault password.",
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 24),

                // Old Password Field
                TextField(
                  controller: oldTc,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Current Password",
                    prefixIcon: const Icon(Icons.password),
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
                const SizedBox(height: 16),

                // New Password Field
                TextField(
                  controller: newTc,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "New Password (Min 6 chars)",
                    prefixIcon: const Icon(Icons.lock_reset),
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
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (oldTc.text.isEmpty) {
                            UIHelpers.showSnackBar(
                              context,
                              message: "Please enter your current password.",
                              isError: true,
                            );
                            return;
                          }
                          if (newTc.text.length < 6) {
                            UIHelpers.showSnackBar(
                              context,
                              message:
                                  "New password must be at least 6 characters.",
                              isError: true,
                            );
                            return;
                          }

                          setSheetState(() => isLoading = true);
                          try {
                            final email = Supabase
                                .instance
                                .client
                                .auth
                                .currentUser!
                                .email!;

                            // 1. Double verify the auth token natively!
                            await Supabase.instance.client.auth
                                .signInWithPassword(
                                  email: email,
                                  password: oldTc.text,
                                );

                            // 2. Commit the new password securely
                            await ref
                                .read(authRepositoryProvider)
                                .updatePassword(newTc.text);

                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                              UIHelpers.showSnackBar(
                                context,
                                message:
                                    "Vault Access Password successfully updated!",
                              );
                            }
                          } on AuthException catch (e) {
                            if (e.message == 'Invalid login credentials') {
                              if (ctx.mounted)
                                UIHelpers.showSnackBar(
                                  context,
                                  message: "Incorrect current password.",
                                  isError: true,
                                );
                            } else {
                              if (ctx.mounted)
                                UIHelpers.showSnackBar(
                                  context,
                                  message: e.message,
                                  isError: true,
                                );
                            }
                          } catch (e) {
                            if (ctx.mounted)
                              UIHelpers.showSnackBar(
                                context,
                                message: "Server timeout.",
                                isError: true,
                              );
                          } finally {
                            setSheetState(() => isLoading = false);
                          }
                        },
                  child: isLoading
                      ? const SpinKitPulse(color: Colors.white, size: 24)
                      : const Text(
                          "UPDATE VAULT PASSWORD",
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsProvider);
    final user = Supabase.instance.client.auth.currentUser;
    final String email = user?.email ?? 'Unknown Email';

    final bool isEmailUser = user?.appMetadata['provider'] == 'email';
    final bool isDark = ref.watch(themeNotifierProvider) == ThemeMode.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          "Wallets & Settings",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, "PROFILE"),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  radius: 24,
                  child: Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    email,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            _buildHeader(context, "CONNECTED WALLETS"),
            accountsAsync.when(
              loading: () => Center(
                child: SpinKitPulse(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              error: (e, st) =>
                  const Center(child: Text("Error fetching accounts")),
              data: (accounts) {
                if (accounts.isEmpty)
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text("No accounts connected."),
                    ),
                  );
                return Column(
                  children: accounts.map((acc) {
                    bool isPlaid =
                        acc.type == 'depository' || acc.type == 'credit';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outlineVariant.withOpacity(0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isPlaid ? Icons.account_balance : Icons.wallet,
                            color: isPlaid
                                ? Colors.blue
                                : Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  acc.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  isPlaid ? "Plaid Secured" : "Manual Wallet",
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.5),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            acc.balance.current < 0
                                ? "-\$${UIHelpers.formatCompactNumber(acc.balance.current.abs())}"
                                : "\$${UIHelpers.formatCompactNumber(acc.balance.current)}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 32),

            _buildHeader(context, "APP PREFERENCES"),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
              title: const Text("Dark Theme Persistence"),
              trailing: Switch(
                value: isDark,
                onChanged: (val) =>
                    ref.read(themeNotifierProvider.notifier).toggleTheme(),
              ),
            ),

            if (isEmailUser) ...[
              const Divider(height: 32),
              _buildHeader(context, "SECURITY"),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.password),
                title: const Text("Change Password"),
                trailing: const Icon(Icons.edit),
                onTap: () => _showChangePasswordSheet(context, ref),
              ),
            ],

            const Divider(height: 32),

            _buildHeader(context, "DATA CONNECTIONS"),
            ListTile(
              contentPadding: EdgeInsets.zero,
              iconColor: Theme.of(context).colorScheme.primary,
              leading: const Icon(Icons.add_link),
              title: const Text("Link New Bank (Plaid)"),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PlaidConnectScreen()),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              iconColor: Colors.red,
              textColor: Colors.red,
              leading: const Icon(Icons.link_off),
              title: const Text("Disconnect All Banks"),
              onTap: () async {
                await ref.read(tokenRepositoryProvider).deleteAccessToken();
                ref.invalidate(plaidTokenCheckProvider);
                ref.invalidate(accountsProvider);
                ref.invalidate(transactionProvider);
                if (context.mounted) {
                  UIHelpers.showSnackBar(
                    context,
                    message: "Banks Disconnected.",
                    isError: true,
                  );
                }
              },
            ),

            const Divider(height: 32),

            _buildHeader(context, "ABOUT & SUPPORT"),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.info_outline),
              title: const Text("Legal & Terms of Service"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showAboutDialog(
                context: context,
                applicationName: "PennyWise Finance",
                applicationVersion: "v1.0.0",
                applicationIcon: const Icon(
                  Icons.account_balance_wallet,
                  size: 50,
                ),
                children: [
                  const Text(
                    "\nBy utilizing this software you explicitly agree to our full Terms & Conditions and Privacy Policy.",
                  ),
                ],
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              iconColor: Colors.red,
              textColor: Colors.red,
              leading: const Icon(Icons.logout),
              title: const Text("Log Out"),
              titleAlignment: ListTileTitleAlignment.center,
              onTap: () async {
                bool? confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    title: const Text("Secure Logout"),
                    content: const Text(
                      "Are you sure you want to lock the vault and log out?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onError,
                        ),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text("Log Out"),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await ref.read(localCacheProvider).clearUserCache();

                  await const FlutterSecureStorage().delete(
                    key: 'plaid_access_token',
                  );
                  ref.invalidate(accountsProvider);
                  ref.invalidate(transactionProvider);

                  ref.invalidate(plaidTokenCheckProvider);

                  await ref.read(authRepositoryProvider).logout();
                  if (context.mounted) {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  }
                }
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
