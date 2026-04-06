import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pennywise/src/core/provider/providers.dart';
import 'package:pennywise/src/core/utils/ui_helpers.dart';
import 'package:pennywise/src/domain/entities/goal_entity.dart';

class AddGoalSheet extends ConsumerStatefulWidget {
  const AddGoalSheet({super.key});

  @override
  ConsumerState<AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends ConsumerState<AddGoalSheet> {
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController(); // Simple free text
  bool _isLoading = false;

  Future<void> _submitGoal() async {
    if (_amountController.text.isEmpty || _categoryController.text.isEmpty)
      return;
    setState(() => _isLoading = true);

    try {
      final repo = ref.read(financeRepositoryProvider);

      // Use your brand new strict Clean Architecture Entity!
      final newGoal = GoalEntity(
        id: '', // Supabase assigns this securely
        category: _categoryController.text,
        amount: double.parse(_amountController.text),
      );

      await repo.addGoal(newGoal);
      ref.invalidate(goalsProvider); // Instantly redraws the Goals screen!

      if (mounted) {
        UIHelpers.showSnackBar(context, message: 'Goal Created Securely!');
        Navigator.pop(context); // Closes sheet
      }
    } catch (e) {
      if (mounted)
        UIHelpers.showSnackBar(
          context,
          message: 'Error creating goal.',
          isError: true,
        );
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Set Custom Budget",
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _categoryController,
            decoration: InputDecoration(
              hintText: 'Goal Category (e.g. Travel)',
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: 'Max limit (e.g. \$200)',
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            onPressed: _isLoading ? null : _submitGoal,
            child: Text(
              "CREATE GOAL",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
