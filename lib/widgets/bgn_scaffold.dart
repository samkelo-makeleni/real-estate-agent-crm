import 'package:flutter/material.dart';

import '../core/routes/app_routes.dart';
import 'bgn_bottom_navigation_bar.dart';
import 'bgn_logo.dart';
import 'bgn_top_navigation_bar.dart';

class BgnScaffold extends StatelessWidget {
  const BgnScaffold({
    super.key,
    required this.currentRoute,
    required this.body,
    this.title,
    this.floatingActionButton,
  });

  final String currentRoute;
  final Widget body;
  final String? title;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 76,
        title: title == null
            ? const BgnLogo()
            : Row(
                children: [
                  const BgnLogo(compact: true),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title!,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
        actions: [
          IconButton(
            tooltip: 'Add lead',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.addLead),
            icon: const Icon(Icons.mark_email_unread),
          ),
          IconButton(
            tooltip: 'Profile',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
            icon: const Icon(Icons.person),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: BgnTopNavigationBar(currentRoute: currentRoute),
        ),
      ),
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: BgnBottomNavigationBar(currentRoute: currentRoute),
    );
  }
}
