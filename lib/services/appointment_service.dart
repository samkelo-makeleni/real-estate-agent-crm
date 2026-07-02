import '../models/appointment_model.dart';

class AppointmentService {
  final List<AppointmentModel> _appointments = [];

  List<AppointmentModel> watchAppointments(String agentId) {
    return _appointments
        .where((appointment) => appointment.agentId == agentId)
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  Future<void> bookAppointment(AppointmentModel appointment) async {
    _appointments.add(appointment);
  }
}
