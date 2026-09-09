import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Persistent shell holding the bottom NavigationBar for the 5 core tabs.
class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  static const _tabs = [
    _NavTab(path: '/home', icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
    _NavTab(path: '/assistant', icon: Icons.auto_awesome_outlined, activeIcon: Icons.auto_awesome, label: 'Assistant'),
    _NavTab(path: '/compliance', icon: Icons.track_changes_outlined, activeIcon: Icons.track_changes, label: 'Compliance'),
    _NavTab(path: '/locator', icon: Icons.location_on_outlined, activeIcon: Icons.location_on, label: 'Locator'),
    _NavTab(path: '/profile', icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = _tabs.indexWhere((tab) => location.startsWith(tab.path));
    return index == -1 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => context.go(_tabs[index].path),
        destinations: _tabs
            .map((tab) => NavigationDestination(
                  icon: Icon(tab.icon),
                  selectedIcon: Icon(tab.activeIcon),
                  label: tab.label,
                ))
            .toList(),
      ),
    );
  }
}

class _NavTab {
  final String path;
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavTab({
    required this.path,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
