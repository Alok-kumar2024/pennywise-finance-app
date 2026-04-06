import 'package:flutter/material.dart';
import 'package:pennywise/src/presentations/screens/goals/goals_screen.dart';
import 'package:pennywise/src/presentations/screens/home/home_screen.dart';
import 'package:pennywise/src/presentations/screens/insights/insights_screen.dart';
import 'package:pennywise/src/presentations/screens/transaction/transactions_screen.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreen();
}

class _MainLayoutScreen extends State<MainLayoutScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const TransactionsScreen(),
    const InsightsScreen(),
    const GoalsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          setState(() {
            _currentIndex = 0;
          });
        }
      },
      child: Scaffold(
        body: _screens[_currentIndex],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: 'Transactions',
            ),
            NavigationDestination(
              icon: Icon(Icons.pie_chart_outline),
              selectedIcon: Icon(Icons.pie_chart),
              label: 'Insights',
            ),
            NavigationDestination(
              icon: Icon(Icons.track_changes_outlined),
              selectedIcon: Icon(Icons.track_changes),
              label: 'Goals',
            ),
          ],
        ),
      ),
    );
  }
}
