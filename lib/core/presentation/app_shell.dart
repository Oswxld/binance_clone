import 'package:flutter/material.dart';

import '../../features/home/presentation/home_screen.dart';
import '../../features/invest/presentation/invest_screen.dart';
import '../../features/markets/presentation/markets_screen.dart';
import 'app_bottom_navigation.dart';

/// The bottom navigation belongs to the application shell, not individual tabs.
/// Switching tabs only replaces the page content, preserving navigation layout
/// and each tab's state (including scroll position) in an IndexedStack.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppTab _selected = AppTab.home;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      body: SafeArea(
        top: true,
        bottom: true,
        child: Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: _selected.index,
                children: const [
                  HomeScreen(),
                  MarketsScreen(),
                  InvestScreen(),
                ],
              ),
            ),
            AppBottomNavigation(
              selected: _selected,
              onSelect: (tab) {
                if (tab != _selected) {
                  setState(() => _selected = tab);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
