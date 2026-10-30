import 'package:flutter/material.dart';

import '../assistant/screens/home_screen.dart';
import '../directory/directory_screen.dart';
import '../updates/updates_screen.dart';

/// The three places in Raah: ask, what's new, and which website to use.
class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _tab, children: const [
        HomeScreen(),
        UpdatesScreen(),
        DirectoryScreen(),
      ]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.mic_none_rounded),
              selectedIcon: Icon(Icons.mic_rounded),
              label: 'Ask'),
          NavigationDestination(
              icon: Icon(Icons.notifications_none_rounded),
              selectedIcon: Icon(Icons.notifications_rounded),
              label: 'Updates'),
          NavigationDestination(
              icon: Icon(Icons.travel_explore_outlined),
              selectedIcon: Icon(Icons.travel_explore_rounded),
              label: 'Websites'),
        ],
      ),
    );
  }
}
