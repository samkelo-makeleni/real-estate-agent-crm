import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../viewmodels/app_state_provider.dart';
import '../../widgets/bgn_scaffold.dart';
import '../../widgets/property_card.dart';

class PropertiesScreen extends StatelessWidget {
  const PropertiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final properties = AppStateProvider.of(context).agentProperties;

    return BgnScaffold(
      currentRoute: AppRoutes.properties,
      title: 'Property List',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addProperty),
        icon: const Icon(Icons.add_home),
        label: const Text('Add'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: properties.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final property = properties[index];
          return PropertyCard(
            property: property,
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.addProperty,
                arguments: property.id,
              );
            },
          );
        },
      ),
    );
  }
}
