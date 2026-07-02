import 'package:flutter/material.dart';

import '../core/constants/app_theme.dart';
import '../core/routes/app_routes.dart';

class BgnTopNavigationBar extends StatelessWidget {
  const BgnTopNavigationBar({super.key, required this.currentRoute});

  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    const items = [
      // _TopNavItem('Properties', AppRoutes.properties, Icons.home_work),
      // _TopNavItem('New Devs', AppRoutes.properties, Icons.domain_add),
      _TopNavItem('About', AppRoutes.dashboard, Icons.info_outline),
      // _TopNavItem('Team', AppRoutes.profile, Icons.groups),
      // _TopNavItem('Tools', AppRoutes.dashboard, Icons.tune),
      // _TopNavItem('Enquire', AppRoutes.addLead, Icons.mark_email_unread),
    ];

    return Material(
      color: Colors.white,
      child: SizedBox(
        height: 48,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(width: 4),
          itemBuilder: (context, index) {
            final item = items[index];
            final selected = currentRoute == item.route;

            return TextButton.icon(
              onPressed: () => _navigate(context, item.route),
              icon: Icon(item.icon, size: 18),
              label: Text(item.label),
              style: TextButton.styleFrom(
                foregroundColor: selected ? AppTheme.navy : AppTheme.ink,
                backgroundColor: selected
                    ? AppTheme.gold.withValues(alpha: 0.14)
                    : Colors.transparent,
                textStyle: const TextStyle(fontWeight: FontWeight.w800),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _navigate(BuildContext context, String route) {
    if (ModalRoute.of(context)?.settings.name == route) return;
    Navigator.pushNamed(context, route);
  }
}

class _TopNavItem {
  const _TopNavItem(this.label, this.route, this.icon);

  final String label;
  final String route;
  final IconData icon;
}
