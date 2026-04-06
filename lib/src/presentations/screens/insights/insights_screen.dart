import 'package:animate_do/animate_do.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pennywise/src/core/provider/providers.dart';
import 'package:pennywise/src/core/utils/ui_helpers.dart'; // IMPORTANT IMPORT!

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. We grab the live stream of your transactions!
    final txAsync = ref.watch(transactionProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          "Spending Insights",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: txAsync.when(
        loading: () => Center(
          child: SpinKitPulse(color: Theme.of(context).colorScheme.primary),
        ),
        error: (e, st) =>
            const Center(child: Text("Error generating insights")),
        data: (transactions) {
          // 2. MATHEMATICS: Group the spending dynamically!
          final Map<String, double> categoryTotals = {};
          final Map<String, int> transactionCounts = {};
          double totalSpending = 0;
          double thisWeekSpend = 0;
          double lastWeekSpend = 0;
          final DateTime now = DateTime.now();

          for (var tx in transactions) {
            if (tx.amount > 0) {
              // Plaid Safe Fallback logic!
              final cat = tx.finance.primary;

              categoryTotals[cat] = (categoryTotals[cat] ?? 0) + tx.amount;
              totalSpending += tx.amount;

              transactionCounts[tx.name] = (transactionCounts[tx.name] ?? 0) + 1;

              final txDate = DateTime.parse(tx.date);
              final difference = now.difference(txDate).inDays;
              if (difference <= 7) {
                thisWeekSpend += tx.amount;
              } else if (difference <= 14) {
                lastWeekSpend += tx.amount;
              }
            }
          }

          if (totalSpending == 0) {
            return const Center(
              child: Text("Not enough spending data to analyze!"),
            );
          }

          String mostFrequentTx = "None";
          int maxFreq = 0;
          transactionCounts.forEach((key, value) {
            if (value > maxFreq) {
              maxFreq = value;
              mostFrequentTx = key;
            }
          });

          String trendText = "No previous data";
          IconData trendIcon = Icons.trending_flat;
          Color trendColor = Colors.grey;
          Color trendBgColor = Colors.grey.withOpacity(0.2);

          if (lastWeekSpend > 0) {
            final diff = thisWeekSpend - lastWeekSpend;
            final pct = (diff / lastWeekSpend) * 100;
            if (diff > 0) {
              trendText = "Up ${pct.toStringAsFixed(1)}% from last week";
              trendIcon = Icons.trending_up;
              trendColor = Colors.red;
              trendBgColor = Colors.red.withOpacity(0.2);
            } else {
              trendText = "Down ${pct.abs().toStringAsFixed(1)}% from last week";
              trendIcon = Icons.trending_down;
              trendColor = Colors.green;
              trendBgColor = Colors.green.withOpacity(0.2);
            }
          } else if (thisWeekSpend > 0) {
            trendText = "No data to compare";
            trendIcon = Icons.trending_up;
            trendColor = Colors.orange;
            trendBgColor = Colors.orange.withOpacity(0.2);
          }

          // 3. Find the Highest Category
          String topCategory = "";
          double topAmount = 0;
          categoryTotals.forEach((key, value) {
            if (value > topAmount) {
              topAmount = value;
              topCategory = key;
            }
          });

          // 4. Generate the Dynamic Chart Vectors
          List<PieChartSectionData> pieSections = [];

          categoryTotals.forEach((key, value) {
            final percentage = (value / totalSpending) * 100;
            pieSections.add(
              PieChartSectionData(
                // USES YOUR DYNAMIC APP-WIDE COLOR SYSTEM!
                color: UIHelpers.getCategoryColor(key),
                value: value,
                title: "${percentage.toStringAsFixed(0)}%",
                radius: 60,
                titleStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            );
          });

          // 5. The UI Render
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Highlight Highest Spending Area
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.warning_amber_rounded,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Highest Spending Area",
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onErrorContainer.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              topCategory,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onErrorContainer,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "\$${UIHelpers.formatCompactNumber(topAmount)}",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                FadeInLeft(
                  delay: const Duration(milliseconds: 100),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.repeat,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Most Frequent",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                mostFrequentTx,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "${maxFreq}x",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                FadeInLeft(
                  delay: const Duration(milliseconds: 200),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: trendBgColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            trendIcon,
                            color: trendColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Weekly Trend",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                trendText,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),
                Text(
                  "Spending Breakdown",
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                // The Graphical Chart!
                SizedBox(
                  height: 250,
                  child: PieChart(
                    PieChartData(
                      sections: pieSections,
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // The Legend
                ...categoryTotals.keys.toList().map((key) {
                  final amt = categoryTotals[key]!;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        // Renders your Dynamic Icons next to the text!
                        CircleAvatar(
                          backgroundColor: UIHelpers.getCategoryColor(
                            key,
                          ).withOpacity(0.2),
                          radius: 16,
                          child: Icon(
                            UIHelpers.getCategoryIcon(key),
                            color: UIHelpers.getCategoryColor(key),
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            key,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          "\$${amt.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
