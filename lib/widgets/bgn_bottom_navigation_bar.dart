import 'package:flutter/material.dart';

import '../core/routes/app_routes.dart';

class BgnBottomNavigationBar extends StatelessWidget {
  const BgnBottomNavigationBar({super.key, required this.currentRoute});

  final String currentRoute;

  static const _routes = [
    AppRoutes.dashboard,
    AppRoutes.properties,
    AppRoutes.leads,
    AppRoutes.appointments,
    AppRoutes.profile,
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = _selectedIndexFor(currentRoute);
    final isCompact = MediaQuery.sizeOf(context).width < 380;

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        final route = _routes[index];
        if (route == currentRoute) return;
        Navigator.pushReplacementNamed(context, route);
      },
      destinations: [
        const NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(
          icon: const Icon(Icons.home_work),
          label: isCompact ? 'Homes' : 'Properties',
        ),
        const NavigationDestination(icon: Icon(Icons.people), label: 'Leads'),
        NavigationDestination(
          icon: const Icon(Icons.event),
          label: isCompact ? 'Tours' : 'Viewings',
        ),
        const NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }

  int _selectedIndexFor(String route) {
    return switch (route) {
      AppRoutes.addProperty => _routes.indexOf(AppRoutes.properties),
      AppRoutes.addLead => _routes.indexOf(AppRoutes.leads),
      AppRoutes.bookAppointment => _routes.indexOf(AppRoutes.appointments),
      _ when _routes.contains(route) => _routes.indexOf(route),
      _ => _routes.indexOf(AppRoutes.dashboard),
    };
  }
}
