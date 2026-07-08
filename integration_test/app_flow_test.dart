import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:real_estate_agent_crm/app.dart';
import 'package:real_estate_agent_crm/core/config/supabase_config.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('buyer can launch the app and open property browsing', (
    tester,
  ) async {
    await SupabaseConfig.initialize();
    await tester.pumpWidget(const BgnRealEstateApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Browse properties as buyer'));
    await tester.pumpAndSettle();

    expect(find.text('Property Search'), findsOneWidget);

    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();

    expect(find.text('Find your next property'), findsOneWidget);
  });
}
