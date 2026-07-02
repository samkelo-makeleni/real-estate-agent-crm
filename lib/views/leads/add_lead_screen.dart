import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../viewmodels/app_state_provider.dart';
import '../../widgets/bgn_scaffold.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AddLeadScreen extends StatefulWidget {
  const AddLeadScreen({super.key});

  @override
  State<AddLeadScreen> createState() => _AddLeadScreenState();
}

class _AddLeadScreenState extends State<AddLeadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clientName = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _budget = TextEditingController();
  final _preferredLocation = TextEditingController();
  final _notes = TextEditingController();
  String? _propertyId;
  bool _loadedRouteProperty = false;

  @override
  void dispose() {
    _clientName.dispose();
    _phone.dispose();
    _email.dispose();
    _budget.dispose();
    _preferredLocation.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppStateProvider.of(context);
    final properties = app.publicProperties;
    if (!_loadedRouteProperty) {
      _loadedRouteProperty = true;
      final routePropertyId =
          ModalRoute.of(context)?.settings.arguments as String?;
      if (routePropertyId != null) {
        _propertyId = routePropertyId;
      }
    }
    _propertyId ??= properties.isEmpty ? null : properties.first.id;

    return BgnScaffold(
      currentRoute: AppRoutes.addLead,
      title: 'Add Client Lead',
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomTextField(
              controller: _clientName,
              label: 'Client name',
              icon: Icons.person,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _phone,
              label: 'Phone number',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _email,
              label: 'Email',
              icon: Icons.mail,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _propertyId,
              decoration: const InputDecoration(
                labelText: 'Interested property',
              ),
              items: properties
                  .map(
                    (property) => DropdownMenuItem(
                      value: property.id,
                      child: Text(property.title),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _propertyId = value),
              validator: (value) => value == null ? 'Select a property' : null,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _budget,
              label: 'Budget',
              icon: Icons.savings,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _preferredLocation,
              label: 'Preferred location',
              icon: Icons.map,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _notes,
              label: 'Notes',
              icon: Icons.notes,
              maxLines: 3,
            ),
            const SizedBox(height: 18),
            CustomButton(
              label: 'Save lead',
              icon: Icons.save,
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                await app.addLead(
                  clientName: _clientName.text.trim(),
                  phone: _phone.text.trim(),
                  email: _email.text.trim(),
                  propertyId: _propertyId!,
                  budget: double.tryParse(_budget.text) ?? 0,
                  preferredLocation: _preferredLocation.text.trim(),
                  notes: _notes.text.trim(),
                );
                if (!context.mounted) return;
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
