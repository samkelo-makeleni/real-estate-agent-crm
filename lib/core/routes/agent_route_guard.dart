import 'package:flutter/material.dart';

import '../../viewmodels/app_state_provider.dart';
import 'app_routes.dart';

class AgentRouteGuard extends StatelessWidget {
  const AgentRouteGuard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final app = AppStateProvider.of(context);
    if (app.isInitializingBackend) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (app.currentUser != null) return child;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
    });

    return const Scaffold(body: SizedBox.shrink());
  }
}
