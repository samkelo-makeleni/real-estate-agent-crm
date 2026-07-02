import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../models/lead_model.dart';
import '../../viewmodels/app_state_provider.dart';
import '../../widgets/bgn_scaffold.dart';
import '../../widgets/status_chip.dart';

class LeadsScreen extends StatelessWidget {
  const LeadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final leads = AppStateProvider.of(context).agentLeads;

    return BgnScaffold(
      currentRoute: AppRoutes.leads,
      title: 'Leads List',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addLead),
        icon: const Icon(Icons.person_add),
        label: const Text('Add'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: leads.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final lead = leads[index];
          return Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(lead.clientName),
              subtitle: Text(
                '${lead.preferredLocation} • R ${lead.budget.toStringAsFixed(0)}',
              ),
              trailing: StatusChip(
                label: _leadLabel(lead.status),
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        },
      ),
    );
  }

  String _leadLabel(LeadStatus status) {
    return switch (status) {
      LeadStatus.newLead => 'new',
      LeadStatus.contacted => 'contacted',
      LeadStatus.viewingBooked => 'viewing',
      LeadStatus.offerMade => 'offer',
      LeadStatus.closed => 'closed',
    };
  }
}
