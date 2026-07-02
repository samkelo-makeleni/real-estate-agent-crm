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

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        final route = _routes[index];
        if (route == currentRoute) return;
        Navigator.pushReplacementNamed(context, route);
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.home_work), label: 'Properties'),
        NavigationDestination(icon: Icon(Icons.people), label: 'Enquiries'),
        NavigationDestination(icon: Icon(Icons.event), label: 'Viewings'),
        NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
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
