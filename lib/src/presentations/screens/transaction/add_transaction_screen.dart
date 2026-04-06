import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pennywise/src/core/provider/providers.dart';
import 'package:pennywise/src/core/utils/ui_helpers.dart';
import 'package:pennywise/src/domain/entities/account_entity.dart';
import 'package:pennywise/src/domain/entities/transaction_entity.dart';

class AddTransactionSheet extends ConsumerStatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddTransactionSheet();
}

class _AddTransactionSheet extends ConsumerState<AddTransactionSheet> {
  final _amountController = TextEditingController();
  final _nameController = TextEditingController();
  String _selectedCategory = 'Food & Drink';
  bool _isLoading = false;
  bool _isExpense = true;

  final List<String> _categories = [
    'Food & Drink',
    'Groceries',
    'Transport',
    'Utilities',
    'Shopping',
    'General',
  ];

  final List<String> _incomeCategories = [
    'Salary',
    'Freelance',
    'Gifts',
    'Investments',
    'Transfer',
  ];

  Future<void> _submitTransaction() async {
    if (_amountController.text.isEmpty || _nameController.text.isEmpty) {
      if (mounted) {
        UIHelpers.showSnackBar(
          context,
          message: "Please fill all fields",
          isError: true,
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(financeRepositoryProvider);
      var accounts = await repo.getManualAccounts();

      if (accounts.isEmpty) {
        final newWallet = AccountEntity(
          accountId: "db_handles_this",
          name: "Main Cash Wallet",
          officialName: "Cash",
          mask: "CASH",
          type: "manual",
          subType: "cash",
          balance: BalanceEntity(
            available: 0,
            current: 0,
            isoCurrencyCode: "USD",
            limit: null,
          ),
        );
        await repo.addManualAccount(newWallet);
        accounts = await repo.getManualAccounts();
      }

      final walletId = accounts.first.accountId;

      final newTx = TransactionEntity(
        transactionId: "manual_${DateTime.now().millisecondsSinceEpoch}",
        accountId: walletId,
        amount: _isExpense
            ? double.parse(_amountController.text)
            : -(double.parse(_amountController.text)),
        date: DateTime.now().toIso8601String(),
        name: _nameController.text,
        category: [_selectedCategory],
        pending: false,
        finance: PrimaryFinanceEntity(
          primary: _selectedCategory,
          detailed: 'MANUAL_ENTRY',
        ),
      );

      await repo.addManualTransaction(newTx);
      ref.invalidate(transactionProvider);
      ref.invalidate(accountsProvider);

      if (mounted) {
        UIHelpers.showSnackBar(context, message: 'Transaction securely saved!');

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        UIHelpers.showSnackBar(
          context,
          message: 'Error saving transaction',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        top: 32,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
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

            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isExpense ? "Add Expense" : "Add Income",
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ChoiceChip(
                      label: const Text('Expense'),
                      selected: _isExpense,
                      selectedColor: Colors.red.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: _isExpense
                            ? Colors.red
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                      onSelected: (val) => setState(() {
                        _isExpense = true;
                        _selectedCategory = _categories.first;
                      }),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Income'),
                      selected: !_isExpense,
                      selectedColor: Colors.green.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: !_isExpense
                            ? Colors.green
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                      onSelected: (val) => setState(() {
                        _isExpense = false;
                        _selectedCategory = _incomeCategories.first;
                      }),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Amount
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  prefixText: '\$ ',
                  border: InputBorder.none,
                  hintText: '0.00',
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Merchant
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: _isExpense
                    ? 'Merchant (e.g. Starbucks)'
                    : 'Source (e.g. Employer)',
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

            // Category Picker
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedCategory,
                  items: (_isExpense ? _categories : _incomeCategories)
                      .map(
                        (String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ),
                      )
                      .toList(),
                  onChanged: (newValue) =>
                      setState(() => _selectedCategory = newValue!),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              onPressed: _isLoading ? null : _submitTransaction,
              child: _isLoading
                  ? SpinKitThreeBounce(
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 24,
                    )
                  : Text(
                      "SAVE TRANSACTION",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
