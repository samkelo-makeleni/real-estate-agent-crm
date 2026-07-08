import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_agent_crm/services/appointment_service.dart';
import 'package:real_estate_agent_crm/services/auth_service.dart';
import 'package:real_estate_agent_crm/services/lead_service.dart';
import 'package:real_estate_agent_crm/services/property_service.dart';
import 'package:real_estate_agent_crm/services/storage_service.dart';
import 'package:real_estate_agent_crm/viewmodels/app_state.dart';

void main() {
  AppState buildAppState() {
    return AppState(
      auth: AuthService(),
      properties: PropertyService(),
      leads: LeadService(),
      appointments: AppointmentService(),
      storage: StorageService(),
    )..loadSeedData();
  }

  test('agent can register and sign in through app state', () async {
    final appState = buildAppState();

    await appState.registerAgent(
      name: 'BGN Agent',
      email: ' Agent@BGNRealEstate.co.za ',
      phone: '+27 21 555 0148',
      password: 'demo123',
    );

    expect(appState.currentUser, isNull);

    await appState.login('agent@bgnrealestate.co.za', 'demo123');

    expect(appState.currentUser?.name, 'BGN Agent');
    expect(appState.currentUser?.email, 'agent@bgnrealestate.co.za');
    expect(appState.publicProperties, isNotEmpty);
  });

  test('favorite property toggles on and off', () {
    final appState = buildAppState();
    const propertyId = 'property-seed-1';

    expect(appState.isFavoriteProperty(propertyId), isFalse);

    appState.toggleFavoriteProperty(propertyId);

    expect(appState.isFavoriteProperty(propertyId), isTrue);

    appState.toggleFavoriteProperty(propertyId);

    expect(appState.isFavoriteProperty(propertyId), isFalse);
  });
}
