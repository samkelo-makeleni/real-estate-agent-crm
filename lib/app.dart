import 'package:flutter/material.dart';

import 'core/constants/app_theme.dart';
import 'core/routes/app_router.dart';
import 'core/routes/app_routes.dart';
import 'services/appointment_service.dart';
import 'services/auth_service.dart';
import 'services/lead_service.dart';
import 'services/notification_service.dart';
import 'services/property_service.dart';
import 'services/storage_service.dart';
import 'viewmodels/app_state.dart';
import 'viewmodels/app_state_provider.dart';

class BgnRealEstateApp extends StatelessWidget {
  const BgnRealEstateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppStateProvider(
      notifier: AppState(
        auth: AuthService(),
        properties: PropertyService(),
        leads: LeadService(),
        appointments: AppointmentService(),
        notifications: NotificationService(),
        storage: StorageService(),
      )..loadSeedData(),
      child: MaterialApp(
        title: 'BGN Real Estate',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: AppRoutes.login,
        routes: AppRouter.routes,
      ),
    );
  }
}
