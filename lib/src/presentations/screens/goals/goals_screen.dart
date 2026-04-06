import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pennywise/src/core/provider/providers.dart';
import 'package:pennywise/src/core/utils/ui_helpers.dart';
import 'package:pennywise/src/domain/entities/transaction_entity.dart';
import 'package:pennywise/src/presentations/screens/goals/add_goal_sheet.dart';

class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  int _calculateStreak(List<TransactionEntity> transactions) {
    DateTime? mostRecentExpense;
    for (var tx in transactions) {
      if (tx.amount > 0) {
        DateTime txDate = DateTime.parse(tx.date);
        if (mostRecentExpense == null || txDate.isAfter(mostRecentExpense)) {
          mostRecentExpense = txDate;
        }
      }
    }
    if (mostRecentExpense == null) return 0;
    return DateTime.now().difference(mostRecentExpense).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final txAsync = ref.watch(transactionProvider);
    final goalsAsync = ref.watch(goalsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          "Goals & Habits",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddGoalSheet(),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("New Goal"),
      ),

      body: txAsync.when(
        loading: () => Center(
          child: SpinKitPulse(color: Theme.of(context).colorScheme.primary),
        ),
        error: (e, st) => const Center(child: Text("Error loading goals.")),
        data: (transactions) {
          final streak = _calculateStreak(transactions);
          final isStreakActive = streak > 0;
          final currentMonth = DateTime.now().month;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: 100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FadeInDown(
                    child: Text(
                      "No Spend Challenge",
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Gamify your savings! Build a hot streak by not logging any expenses.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),

                  const SizedBox(height: 60),

                  // The Interactive Flame Graphic!
                  Pulse(
                    infinite: isStreakActive,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isStreakActive
                            ? Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.1)
                            : Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                        boxShadow: isStreakActive
                            ? [
                                BoxShadow(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.4),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                              ]
                            : [],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isStreakActive
                                  ? Icons.local_fire_department
                                  : Icons.ac_unit,
                              size: 80,
                              color: isStreakActive
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey,
                            ),
                            Text(
                              "$streak",
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: isStreakActive
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey,
                              ),
                            ),
                            const Text(
                              "DAYS",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  Text(
                    isStreakActive
                        ? "You are on fire! Keep your wallet closed today to keep the streak alive."
                        : "Your streak is cold! Don't spend any money today to ignite a new streak.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 40),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Monthly Budget Goals",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // The Dynamic Cloud UI Mapped perfectly!
                  goalsAsync.when(
                    loading: () => SpinKitThreeBounce(
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                    error: (err, st) => const Text("Error loading goals"),
                    data: (goals) {
                      if (goals.isEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.outlineVariant.withOpacity(0.3),
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: const Text(
                            "No custom goals set. Tap + to add one!",
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      return Column(
                        children: goals.map((goal) {
                          double totalSpend = 0;
                          for (var tx in transactions) {
                            if (tx.amount > 0 &&
                                DateTime.parse(tx.date).month == currentMonth) {
                              if (tx.finance.primary.toLowerCase().contains(
                                    goal.category.toLowerCase().trim(),
                                  ) ||
                                  tx.name.toLowerCase().contains(
                                    goal.category.toLowerCase().trim(),
                                  )) {
                                totalSpend += tx.amount;
                              }
                            }
                          }

                          double progress = totalSpend / goal.amount;
                          if (progress > 1.0) progress = 1.0;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(20),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      goal.category.toUpperCase(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "\$${UIHelpers.formatCompactNumber(totalSpend)} / \$${UIHelpers.formatCompactNumber(goal.amount)}",
                                          style: TextStyle(
                                            color: progress >= 1.0
                                                ? Colors.red
                                                : Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        // The Brand New Delete Button!
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete_outline,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.3),
                                          ),
                                          onPressed: () async {
                                            await ref
                                                .read(financeRepositoryProvider)
                                                .deleteGoal(goal.id);
                                            ref.invalidate(
                                              goalsProvider,
                                            ); // Instantly redraws without the goal!
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    minHeight: 8,
                                    value: progress,
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest,
                                    color: progress >= 1.0
                                        ? Colors.red
                                        : Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
