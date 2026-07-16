import '../core/config/supabase_config.dart';
import '../models/appointment_model.dart';

class AppointmentService {
  final List<AppointmentModel> _appointments = [];

  Future<void> refreshAgentAppointments(String agentId) async {
    if (!SupabaseConfig.isConfigured) return;

    final rows = await SupabaseConfig.client!
        .from('appointments')
        .select()
        .eq('agent_id', agentId)
        .order('scheduled_for');

    _mergeAppointments(rows.map(_appointmentFromSupabase));
  }

  List<AppointmentModel> watchAppointments(String agentId) {
    return _appointments
        .where((appointment) => appointment.agentId == agentId)
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  Future<void> bookAppointment(AppointmentModel appointment) async {
    if (SupabaseConfig.isConfigured) {
      final saved = await _bookAppointmentInSupabase(appointment);
      _upsertAppointmentInMemory(saved);
      return;
    }

    _upsertAppointmentInMemory(appointment);
  }

  Future<AppointmentModel> _bookAppointmentInSupabase(
    AppointmentModel appointment,
  ) async {
    final client = SupabaseConfig.client!;
    final profile = await client
        .from('profiles')
        .select('agency_id')
        .eq('id', appointment.agentId)
        .single();

    final row = await client
        .from('appointments')
        .insert({
          'agency_id': profile['agency_id'],
          'agent_id': appointment.agentId,
          'property_id': appointment.propertyId.isEmpty
              ? null
              : appointment.propertyId,
          'client_name': appointment.clientName,
          'scheduled_for': appointment.dateTime.toIso8601String(),
          'status': appointment.status.name,
          'notes': appointment.notes,
        })
        .select()
        .single();

    final savedAppointment = _appointmentFromSupabase(row);
    await _upsertViewingReminderInSupabase(
      agencyId: profile['agency_id'] as String,
      appointment: savedAppointment,
    );
    return savedAppointment;
  }

  Future<void> _upsertViewingReminderInSupabase({
    required String agencyId,
    required AppointmentModel appointment,
  }) async {
    final reminderFor = appointment.dateTime.subtract(
      const Duration(minutes: 60),
    );
    if (!reminderFor.isAfter(DateTime.now())) return;

    await SupabaseConfig.client!.from('appointment_reminders').upsert({
      'agency_id': agencyId,
      'appointment_id': appointment.id,
      'agent_id': appointment.agentId,
      'reminder_for': reminderFor.toIso8601String(),
      'channel': 'push',
      'status': 'scheduled',
    }, onConflict: 'appointment_id,agent_id');
  }

  void _mergeAppointments(Iterable<AppointmentModel> appointments) {
    for (final appointment in appointments) {
      _upsertAppointmentInMemory(appointment);
    }
  }

  void _upsertAppointmentInMemory(AppointmentModel appointment) {
    final index = _appointments.indexWhere((item) => item.id == appointment.id);
    if (index == -1) {
      _appointments.add(appointment);
    } else {
      _appointments[index] = appointment;
    }
  }

  AppointmentModel _appointmentFromSupabase(Map<String, dynamic> row) {
    return AppointmentModel(
      id: row['id'] as String,
      propertyId: row['property_id'] as String? ?? '',
      clientName: row['client_name'] as String? ?? '',
      agentId: row['agent_id'] as String? ?? '',
      dateTime:
          DateTime.tryParse(row['scheduled_for'] as String? ?? '') ??
          DateTime.now(),
      status: _appointmentStatusFromSupabase(row['status'] as String?),
      notes: row['notes'] as String? ?? '',
    );
  }

  AppointmentStatus _appointmentStatusFromSupabase(String? status) {
    return AppointmentStatus.values.firstWhere(
      (value) => value.name == status,
      orElse: () => AppointmentStatus.booked,
    );
  }
}
