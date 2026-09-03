import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Persistent shell holding the bottom NavigationBar for the 5 core tabs.
class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  static const _tabs = [
    _NavTab(path: '/home', icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
    _NavTab(path: '/assistant', icon: Icons.chat_bubble_outline, activeIcon: Icons.chat_bubble, label: 'Assistant'),
    _NavTab(path: '/explore', icon: Icons.explore_outlined, activeIcon: Icons.explore, label: 'Explore'),
    _NavTab(path: '/saved', icon: Icons.bookmark_border, activeIcon: Icons.bookmark, label: 'Saved'),
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
