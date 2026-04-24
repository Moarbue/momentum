import 'package:flutter/material.dart';
import 'home_page.dart';
import 'settings_page.dart';
import 'workout_builder.dart';
import '../models/workout.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final GlobalKey<HomePageState> _homePageKey = GlobalKey<HomePageState>();

  late final List<Widget> _pages;

  void _reloadWorkouts() {
    _homePageKey.currentState?.loadWorkouts(showSnackbar: true);
  }

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(key: _homePageKey),
      WorkoutBuilder(workout: Workout(), isQuickStart: true),
      SettingsPage(onImportComplete: _reloadWorkouts),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          // Restart marquees when switching to workouts tab (index 0)
          if (_currentIndex != 0 && index == 0) {
            _homePageKey.currentState?.restartMarquees();
          }
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'Workouts',
          ),
          NavigationDestination(
            icon: Icon(Icons.bolt_outlined),
            selectedIcon: Icon(Icons.bolt),
            label: 'Quick Start',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
