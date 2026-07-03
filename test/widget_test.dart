import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_agent_crm/app.dart';
import 'package:real_estate_agent_crm/core/constants/app_theme.dart';
import 'package:real_estate_agent_crm/core/routes/app_routes.dart';
import 'package:real_estate_agent_crm/services/appointment_service.dart';
import 'package:real_estate_agent_crm/services/auth_service.dart';
import 'package:real_estate_agent_crm/services/lead_service.dart';
import 'package:real_estate_agent_crm/services/property_service.dart';
import 'package:real_estate_agent_crm/services/storage_service.dart';
import 'package:real_estate_agent_crm/viewmodels/app_state.dart';
import 'package:real_estate_agent_crm/viewmodels/app_state_provider.dart';
import 'package:real_estate_agent_crm/views/appointments/appointment_booking_screen.dart';

void main() {
  testWidgets('app opens on the agent sign in screen', (tester) async {
    await tester.pumpWidget(const BgnRealEstateApp());

    expect(find.text('BGN'), findsOneWidget);
    expect(find.text('Real Estate agent app'), findsOneWidget);
    expect(find.text('Agent sign in'), findsOneWidget);
    expect(find.text('New agent? Register first'), findsOneWidget);
  });

  test('agent can register and sign in through app state', () async {
    final appState = AppState(
      auth: AuthService(),
      properties: PropertyService(),
      leads: LeadService(),
      appointments: AppointmentService(),
      storage: StorageService(),
    )..loadSeedData();

    await appState.registerAgent(
      name: 'BGN Agent',
      email: 'agent@bgnrealestate.co.za',
      phone: '+27 21 555 0148',
      password: 'demo123',
    );

    expect(appState.currentUser, isNull);

    await appState.login('agent@bgnrealestate.co.za', 'demo123');

    expect(appState.currentUser?.name, 'BGN Agent');
    expect(appState.agentProperties, isNotEmpty);
    expect(appState.agentLeads, isNotEmpty);
    expect(appState.agentAppointments, isNotEmpty);
  });

  testWidgets('agent registration form toggles from sign in', (tester) async {
    await tester.pumpWidget(const BgnRealEstateApp());

    await tester.tap(find.text('New agent? Register first'));
    await tester.pumpAndSettle();

    expect(find.text('Create agent account'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Full name'), findsOneWidget);
    expect(
      find.widgetWithText(TextFormField, 'Phone / WhatsApp'),
      findsOneWidget,
    );
  });

  testWidgets('booking screen fits on narrow phones', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final appState = AppState(
      auth: AuthService(),
      properties: PropertyService(),
      leads: LeadService(),
      appointments: AppointmentService(),
      storage: StorageService(),
    )..loadSeedData();

    await tester.pumpWidget(
      AppStateProvider(
        notifier: appState,
        child: MaterialApp(
          theme: AppTheme.light,
          routes: {
            AppRoutes.bookAppointment: (_) => const AppointmentBookingScreen(),
            AppRoutes.addLead: (_) => const SizedBox.shrink(),
            AppRoutes.profile: (_) => const SizedBox.shrink(),
            AppRoutes.dashboard: (_) => const SizedBox.shrink(),
            AppRoutes.properties: (_) => const SizedBox.shrink(),
            AppRoutes.leads: (_) => const SizedBox.shrink(),
            AppRoutes.appointments: (_) => const SizedBox.shrink(),
          },
          initialRoute: AppRoutes.bookAppointment,
        ),
      ),
    );

    expect(find.text('Book viewing'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
