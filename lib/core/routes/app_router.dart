import 'package:flutter/material.dart';

import '../../views/appointments/appointment_booking_screen.dart';
import '../../views/appointments/appointments_screen.dart';
import '../../views/auth/login_screen.dart';
import '../../views/buyer/buyer_dashboard_screen.dart';
import '../../views/buyer/buyer_properties_screen.dart';
import '../../views/buyer/property_details_screen.dart';
import '../../views/dashboard/dashboard_screen.dart';
import '../../views/leads/add_lead_screen.dart';
import '../../views/leads/leads_screen.dart';
import '../../views/profile/profile_screen.dart';
import '../../views/properties/add_property_screen.dart';
import '../../views/properties/properties_screen.dart';
import 'agent_route_guard.dart';
import 'app_routes.dart';

class AppRouter {
  static Map<String, WidgetBuilder> get routes => {
    AppRoutes.login: (_) => const LoginScreen(),
    AppRoutes.buyerDashboard: (_) => const BuyerDashboardScreen(),
    AppRoutes.buyerProperties: (_) => const BuyerPropertiesScreen(),
    AppRoutes.propertyDetails: (_) => const PropertyDetailsScreen(),
    AppRoutes.dashboard: (_) => const AgentRouteGuard(child: DashboardScreen()),
    AppRoutes.properties: (_) =>
        const AgentRouteGuard(child: PropertiesScreen()),
    AppRoutes.addProperty: (_) =>
        const AgentRouteGuard(child: AddPropertyScreen()),
    AppRoutes.leads: (_) => const AgentRouteGuard(child: LeadsScreen()),
    AppRoutes.addLead: (_) => const AgentRouteGuard(child: AddLeadScreen()),
    AppRoutes.appointments: (_) =>
        const AgentRouteGuard(child: AppointmentsScreen()),
    AppRoutes.bookAppointment: (_) =>
        const AgentRouteGuard(child: AppointmentBookingScreen()),
    AppRoutes.profile: (_) => const AgentRouteGuard(child: ProfileScreen()),
  };
}
