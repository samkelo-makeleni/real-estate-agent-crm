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
import 'app_routes.dart';

class AppRouter {
  static Map<String, WidgetBuilder> get routes => {
    AppRoutes.login: (_) => const LoginScreen(),
    AppRoutes.buyerDashboard: (_) => const BuyerDashboardScreen(),
    AppRoutes.buyerProperties: (_) => const BuyerPropertiesScreen(),
    AppRoutes.propertyDetails: (_) => const PropertyDetailsScreen(),
    AppRoutes.dashboard: (_) => const DashboardScreen(),
    AppRoutes.properties: (_) => const PropertiesScreen(),
    AppRoutes.addProperty: (_) => const AddPropertyScreen(),
    AppRoutes.leads: (_) => const LeadsScreen(),
    AppRoutes.addLead: (_) => const AddLeadScreen(),
    AppRoutes.appointments: (_) => const AppointmentsScreen(),
    AppRoutes.bookAppointment: (_) => const AppointmentBookingScreen(),
    AppRoutes.profile: (_) => const ProfileScreen(),
  };
}
