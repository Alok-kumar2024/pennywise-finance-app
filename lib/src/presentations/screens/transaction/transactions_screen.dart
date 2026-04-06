import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pennywise/src/core/provider/providers.dart';
import 'package:pennywise/src/core/utils/ui_helpers.dart';
import 'package:pennywise/src/presentations/screens/transaction/add_transaction_screen.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  String _searchQuery = "";

  // MAGIC FIX: We instantly store deleted IDs here so the UI hides them before the Database finishes!
  final Set<String> _deletedIds = {};

  Future<void> _deleteTx(String id) async {
    // 1. Instantly hide it from the UI!
    setState(() {
      _deletedIds.add(id);
    });

    // 2. Tell the Database to delete it in the background
    try {
      await ref.read(financeRepositoryProvider).deleteManualTransaction(id);
      ref.invalidate(transactionProvider); // 3. Silently refresh Riverpod
      ref.invalidate(accountsProvider);
      if (mounted)
        UIHelpers.showSnackBar(context, message: "Transaction deleted.");
    } catch (e) {
      if (mounted)
        UIHelpers.showSnackBar(
          context,
          message: "Could not delete.",
          isError: true,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final txAsync = ref.watch(transactionProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          "All Transactions",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: TextField(
              onChanged: (value) =>
                  setState(() => _searchQuery = value.toLowerCase()),
              decoration: InputDecoration(
                hintText: "Search merchants or categories...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Expanded(
            child: txAsync.when(
              loading: () => Center(
                child: SpinKitPulse(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              error: (e, st) =>
                  const Center(child: Text("Error fetching data!")),
              data: (transactions) {
                // We filter out any items you JUST swiped!
                final filteredList = transactions.where((tx) {
                  return !_deletedIds.contains(
                        tx.transactionId,
                      ) && // <--- MAGIC FIX IN ACTION
                      (tx.name.toLowerCase().contains(_searchQuery) ||
                          tx.finance.primary.toLowerCase().contains(
                            _searchQuery,
                          ));
                }).toList();

                if (filteredList.isEmpty) {
                  return const Center(child: Text("No transactions found."));
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final tx = filteredList[index];

                    return Dismissible(
                      key: Key(tx.transactionId),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 32),
                        color: Theme.of(context).colorScheme.error,
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      onDismissed: (direction) => _deleteTx(tx.transactionId),
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
                                  UIHelpers.getCategoryIcon(tx.finance.primary),
                                  color: UIHelpers.getCategoryColor(
                                    tx.finance.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddTransactionSheet(),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Manual Add"),
      ),
    );
  }
}
