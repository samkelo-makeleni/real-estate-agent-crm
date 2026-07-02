import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_agent_crm/app.dart';

void main() {
  testWidgets('BGN login opens the agent dashboard', (tester) async {
    await tester.pumpWidget(const BgnRealEstateApp());

    expect(find.text('BGN'), findsOneWidget);
    expect(find.text('Real Estate agent app'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.login));
    await tester.pumpAndSettle();

    expect(find.text('Property Search'), findsOneWidget);
    expect(find.text('Sales'), findsOneWidget);
    expect(find.text('Properties'), findsWidgets);
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.drag(find.byType(ListView).first, const Offset(0, -700));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('client-centred real estate agency'),
      findsOneWidget,
    );
  });
}
