import 'package:flutter/material.dart';
import '../theme.dart';
import 'home_page.dart';
import 'explore_page.dart';
import 'cart_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _pages = <Widget>[
    HomePage(),
    ExplorePage(),
    CartPage(),
    Center(child: Text('Profile')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: IndexedStack(index: _index, children: _pages)),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: Colors.transparent,
          height: 60,
          labelTextStyle: WidgetStateProperty.resolveWith((s) => TextStyle(
                fontSize: 10,
                fontWeight: s.contains(WidgetState.selected)
                    ? FontWeight.w600
                    : FontWeight.w400,
                color: s.contains(WidgetState.selected)
                    ? AppColors.primary
                    : AppColors.muted,
              )),
          iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
                size: 20,
                color: s.contains(WidgetState.selected)
                    ? AppColors.primary
                    : AppColors.muted,
              )),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home'),
            NavigationDestination(
                icon: Icon(Icons.explore_outlined),
                selectedIcon: Icon(Icons.explore),
                label: 'Explore'),
            NavigationDestination(
                icon: Icon(Icons.shopping_cart_outlined),
                selectedIcon: Icon(Icons.shopping_cart),
                label: 'Cart'),
            NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
