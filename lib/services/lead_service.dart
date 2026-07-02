import '../models/lead_model.dart';

class LeadService {
  final List<LeadModel> _leads = [];

  List<LeadModel> watchLeads(String agentId) {
    return _leads.where((lead) => lead.agentId == agentId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> addLead(LeadModel lead) async {
    _leads.add(lead);
  }
}
