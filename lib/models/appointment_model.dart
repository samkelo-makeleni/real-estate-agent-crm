enum AppointmentStatus { booked, completed, cancelled, rescheduled }

class AppointmentModel {
  const AppointmentModel({
    required this.id,
    required this.propertyId,
    required this.clientName,
    required this.agentId,
    required this.dateTime,
    required this.status,
    required this.notes,
  });

  final String id;
  final String propertyId;
  final String clientName;
  final String agentId;
  final DateTime dateTime;
  final AppointmentStatus status;
  final String notes;
}
