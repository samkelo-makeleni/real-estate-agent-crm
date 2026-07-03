import '../core/config/supabase_config.dart';
import '../models/lead_model.dart';

class LeadService {
  final List<LeadModel> _leads = [];

  Future<void> refreshAgentLeads(String agentId) async {
    if (!SupabaseConfig.isConfigured) return;

    final rows = await SupabaseConfig.client!
        .from('leads')
        .select()
        .eq('agent_id', agentId)
        .order('created_at', ascending: false);

    _mergeLeads(rows.map(_leadFromSupabase));
  }

  List<LeadModel> watchLeads(String agentId) {
    return _leads.where((lead) => lead.agentId == agentId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> addLead(LeadModel lead) async {
    if (SupabaseConfig.isConfigured) {
      final saved = await _addLeadToSupabase(lead);
      _upsertLeadInMemory(saved);
      return;
    }

    _upsertLeadInMemory(lead);
  }

  Future<LeadModel> _addLeadToSupabase(LeadModel lead) async {
    final client = SupabaseConfig.client!;
    final profile = await client
        .from('profiles')
        .select('agency_id')
        .eq('id', lead.agentId)
        .single();

    final row = await client
        .from('leads')
        .insert({
          'agency_id': profile['agency_id'],
          'agent_id': lead.agentId,
          'property_id': lead.propertyId.isEmpty ? null : lead.propertyId,
          'client_name': lead.clientName,
          'phone': lead.phone,
          'email': lead.email,
          'budget': lead.budget,
          'preferred_location': lead.preferredLocation,
          'status': _leadStatusToSupabase(lead.status),
          'notes': lead.notes,
        })
        .select()
        .single();

    return _leadFromSupabase(row);
  }

  void _mergeLeads(Iterable<LeadModel> leads) {
    for (final lead in leads) {
      _upsertLeadInMemory(lead);
    }
  }

  void _upsertLeadInMemory(LeadModel lead) {
    final index = _leads.indexWhere((item) => item.id == lead.id);
    if (index == -1) {
      _leads.add(lead);
    } else {
      _leads[index] = lead;
    }
  }

  LeadModel _leadFromSupabase(Map<String, dynamic> row) {
    return LeadModel(
      id: row['id'] as String,
      clientName: row['client_name'] as String? ?? '',
      phone: row['phone'] as String? ?? '',
      email: row['email'] as String? ?? '',
      propertyId: row['property_id'] as String? ?? '',
      agentId: row['agent_id'] as String? ?? '',
      budget: (row['budget'] as num?)?.toDouble() ?? 0,
      preferredLocation: row['preferred_location'] as String? ?? '',
      status: _leadStatusFromSupabase(row['status'] as String?),
      notes: row['notes'] as String? ?? '',
      createdAt:
          DateTime.tryParse(row['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  String _leadStatusToSupabase(LeadStatus status) {
    return switch (status) {
      LeadStatus.newLead => 'new_lead',
      LeadStatus.contacted => 'contacted',
      LeadStatus.viewingBooked => 'viewing_booked',
      LeadStatus.offerMade => 'offer_made',
      LeadStatus.closed => 'closed',
    };
  }

  LeadStatus _leadStatusFromSupabase(String? status) {
    return switch (status) {
      'contacted' => LeadStatus.contacted,
      'viewing_booked' => LeadStatus.viewingBooked,
      'offer_made' => LeadStatus.offerMade,
      'closed' => LeadStatus.closed,
      'new_lead' || _ => LeadStatus.newLead,
    };
  }
}
