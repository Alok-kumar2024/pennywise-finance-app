import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pennywise/src/core/provider/providers.dart';
import 'package:pennywise/src/core/utils/ui_helpers.dart';
import 'package:pennywise/src/presentations/screens/accounts/accounts_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreen();
}

class _HomeScreen extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsProvider);
    final txAsync = ref.watch(transactionProvider);

    // Extacts the exact name you Typed into the Sign Up page!
    final String displayName =
        Supabase
            .instance
            .client
            .auth
            .currentUser
            ?.userMetadata?['display_name'] ??
        'Friend';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. The Welcome Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateTime.now().hour < 12
                              ? "Good Morning,"
                              : DateTime.now().hour < 17
                              ? "Good Afternoon,"
                              : "Good Evening,",
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.5),
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "$displayName ",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        // Opens the new Wallets Page!
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AccountsScreen(),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.secondaryContainer,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          Icons.account_balance_wallet_outlined,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Dynamic Balance Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withAlpha(200),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total Balance",
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimary.withOpacity(0.8),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),

                      accountsAsync.when(
                        loading: () => SpinKitThreeBounce(
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 24,
                        ),
                        error: (e, st) => Text(
                          "Error",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        data: (accounts) {
                          double total = accounts.fold(
                            0,
                            (sum, item) => sum + item.balance.current,
                          );
                          return FadeInDown(
                            child: Text(
                              "\$${UIHelpers.formatCompactNumber(total)}",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      txAsync.when(
                        loading: () => SpinKitThreeBounce(
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 20,
                        ),
                        error: (e, st) => const SizedBox(),
                        data: (transactions) {
                          double income = 0;
                          double expense = 0;

                          for (var tx in transactions) {
                            if (tx.amount < 0) {
                              income += tx.amount.abs();
                            } else {
                              expense += tx.amount;
                            }
                          }
                          return FadeInUp(
                            delay: const Duration(milliseconds: 100),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: _buildDataCard(
                                    context,
                                    Icons.arrow_downward,
                                    "Income",
                                    "+\$${UIHelpers.formatCompactNumber(income)}",
                                  ),
                                ),
                                Expanded(
                                  child: _buildDataCard(
                                    context,
                                    Icons.arrow_upward,
                                    "Expense",
                                    "-\$${UIHelpers.formatCompactNumber(expense)}",
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Transactions Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Recent Transactions",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            txAsync.when(
              loading: () => SliverToBoxAdapter(
                child: Center(
                  child: SpinKitPulse(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              error: (e, st) => const SliverToBoxAdapter(
                child: Center(child: Text("Error fetching data!")),
              ),
              data: (transactions) {
                if (transactions.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text("No transactions yet!"),
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final tx = transactions[index];

                      return FadeInUp(
                        delay: Duration(milliseconds: index * 50),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 8,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withOpacity(0.3),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outlineVariant.withOpacity(0.5),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    UIHelpers.getCategoryIcon(
                                      tx.finance.primary,
                                    ),
                                    color: UIHelpers.getCategoryColor(
                                      tx.finance.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tx.name,
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${tx.finance.primary} • ${tx.date.substring(0, 10)}",
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.5),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  tx.amount < 0
                                      ? "+\$${UIHelpers.formatCompactNumber(tx.amount.abs())}"
                                      : "-\$${UIHelpers.formatCompactNumber(tx.amount)}",
                                  style: TextStyle(
                                    color: tx.amount < 0
                                        ? Colors.green
                                        : Theme.of(context).colorScheme.error,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: transactions.length > 5
                        ? 5
                        : transactions.length, // Only show top 5 here
                  ),
                );
              },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
            // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildDataCard(
    BuildContext context,
    IconData icon,
    String label,
    String amount,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.onPrimary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onPrimary.withOpacity(0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                amount,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
