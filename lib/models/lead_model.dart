enum LeadStatus { newLead, contacted, viewingBooked, offerMade, closed }

class LeadModel {
  const LeadModel({
    required this.id,
    required this.clientName,
    required this.phone,
    required this.email,
    required this.propertyId,
    required this.agentId,
    required this.budget,
    required this.preferredLocation,
    required this.status,
    required this.notes,
    required this.createdAt,
  });

  final String id;
  final String clientName;
  final String phone;
  final String email;
  final String propertyId;
  final String agentId;
  final double budget;
  final String preferredLocation;
  final LeadStatus status;
  final String notes;
  final DateTime createdAt;
}
