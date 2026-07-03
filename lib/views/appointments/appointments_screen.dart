import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../viewmodels/app_state_provider.dart';
import '../../widgets/bgn_scaffold.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appointments = AppStateProvider.of(context).agentAppointments;

    return BgnScaffold(
      currentRoute: AppRoutes.appointments,
      title: 'Viewing Appointments',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            Navigator.pushNamed(context, AppRoutes.bookAppointment),
        icon: const Icon(Icons.event_available),
        label: const Text('Book'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: appointments.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_month),
              title: Text(appointment.clientName),
              subtitle: Text(
                '${appointment.dateTime.month}/${appointment.dateTime.day}/${appointment.dateTime.year} '
                '${appointment.dateTime.hour.toString().padLeft(2, '0')}:'
                '${appointment.dateTime.minute.toString().padLeft(2, '0')}',
              ),
              trailing: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 96),
                child: Text(
                  appointment.status.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
