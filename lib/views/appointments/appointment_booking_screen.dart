import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../viewmodels/app_state_provider.dart';
import '../../widgets/bgn_scaffold.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AppointmentBookingScreen extends StatefulWidget {
  const AppointmentBookingScreen({super.key});

  @override
  State<AppointmentBookingScreen> createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clientName = TextEditingController();
  final _notes = TextEditingController();
  String? _propertyId;
  DateTime _dateTime = DateTime.now().add(const Duration(days: 1));
  bool _loadedRouteProperty = false;

  @override
  void dispose() {
    _clientName.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppStateProvider.of(context);
    final currentUser = app.currentUser;
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
      currentRoute: AppRoutes.bookAppointment,
      title: 'Appointment Booking',
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
            DropdownButtonFormField<String>(
              initialValue: _propertyId,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Property'),
              items: properties
                  .map(
                    (property) => DropdownMenuItem(
                      value: property.id,
                      child: Text(
                        property.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              selectedItemBuilder: (context) {
                return properties
                    .map(
                      (property) => Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          property.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList();
              },
              onChanged: (value) => setState(() => _propertyId = value),
              validator: (value) => value == null ? 'Select a property' : null,
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.schedule),
                title: const Text('Date and time'),
                subtitle: Text(_dateTime.toString().substring(0, 16)),
                trailing: const Icon(Icons.edit_calendar),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    initialDate: _dateTime,
                  );
                  if (date == null || !context.mounted) return;
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_dateTime),
                  );
                  if (time == null) return;
                  setState(() {
                    _dateTime = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      time.hour,
                      time.minute,
                    );
                  });
                },
              ),
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
              label: 'Book viewing',
              icon: Icons.event_available,
              onPressed: () async {
                if (currentUser == null) {
                  ScaffoldMessenger.of(context)
                    ..clearSnackBars()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text('Sign in as an agent to book viewings.'),
                      ),
                    );
                  return;
                }
                if (!_formKey.currentState!.validate()) return;
                await app.bookAppointment(
                  propertyId: _propertyId!,
                  clientName: _clientName.text.trim(),
                  dateTime: _dateTime,
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
