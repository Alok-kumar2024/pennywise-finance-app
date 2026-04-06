import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pennywise/src/core/provider/providers.dart';
import 'package:pennywise/src/core/utils/ui_helpers.dart';
import 'package:pennywise/src/presentations/navigation/main_layout_screen.dart';
import 'package:pennywise/src/presentations/providers/plaid_provider.dart';
import 'package:plaid_flutter/plaid_flutter.dart';

class PlaidConnectScreen extends ConsumerStatefulWidget {
  const PlaidConnectScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PlaidConnectScreen();
}

class _PlaidConnectScreen extends ConsumerState<PlaidConnectScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    PlaidLink.onSuccess.listen(_onPlaidSuccess);
    PlaidLink.onExit.listen(_onPlaidExit);
  }

  void _onPlaidSuccess(LinkSuccess event) async {
    await ref.read(plaidLinkProvider.notifier).linkAccount(event.publicToken);

    ref.invalidate(plaidTokenCheckProvider);

    ref.invalidate(accountsProvider);
    ref.invalidate(transactionProvider);

    if (mounted) {
      UIHelpers.showSnackBar(context, message: "Bank Linked SuccessFully!");
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainLayoutScreen()),
        );
      }
    }
  }

  void _onPlaidExit(LinkExit event) {
    if (mounted) {
      UIHelpers.showSnackBar(
        context,
        message: "Plaid connection  cancelled.",
        isError: true,
      );
    }
  }

  Future<void> _launchPlaid() async {
    setState(() => _isLoading = true);

    try {
      // new Link token from dio backend..
      await ref.read(plaidLinkProvider.notifier).prepareLinkToken();

      final linkTokenAsync = ref.read(plaidLinkProvider);

      if (linkTokenAsync.hasValue && linkTokenAsync.value != null) {
        LinkTokenConfiguration linkTokenConfiguration = LinkTokenConfiguration(
          token: linkTokenAsync.value!,
        );

        PlaidLink.create(configuration: linkTokenConfiguration);
        PlaidLink.open();
      } else {
        throw Exception("Could not generate Plaid Link Token");
      }
    } catch (e) {
      if (mounted) {
        UIHelpers.showSnackBar(
          context,
          message: "Error launching Plaid",
          isError: true,
        );
      }
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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Spacer(),

              FadeInDown(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.account_balance,
                    size: 50,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),

              SizedBox(height: 32),

              FadeInUp(
                child: Text(
                  "Connect Your Bank",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: 16),

              FadeInUp(
                delay: Duration(milliseconds: 200),
                child: Text(
                  "PennyWise uses Plaid to securely connect to your bank accounts. We never store your login credentials.",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              Spacer(),

              //Connect Button..
              FadeInUp(
                delay: Duration(milliseconds: 400),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: Size(double.infinity, 56),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: _isLoading ? null : _launchPlaid,
                  child: _isLoading
                      ? SpinKitThreeBounce(
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 24,
                        )
                      : Text(
                          "LINK ACCOUNT",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                ),
              ),

              SizedBox(height: 16),

              FadeInUp(
                delay: const Duration(milliseconds: 500),
                child: TextButton(
                  onPressed: () async {
                    await ref.read(tokenRepositoryProvider).setPlaidSkipped();

                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MainLayoutScreen(),
                        ),
                      );
                    }
                  },
                  child: Text(
                    "Skip & Add Automatically / Manually",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
