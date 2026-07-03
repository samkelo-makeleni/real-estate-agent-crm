import 'package:flutter/material.dart';

import '../../core/constants/app_theme.dart';
import '../../core/routes/app_routes.dart';
import '../../viewmodels/app_state_provider.dart';
import '../../widgets/bgn_scaffold.dart';
import '../../widgets/dashboard_action_tile.dart';
import '../../widgets/dashboard_metric_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppStateProvider.of(context);
    final properties = app.agentProperties;
    final leads = app.agentLeads;
    final appointments = app.agentAppointments;

    return BgnScaffold(
      currentRoute: AppRoutes.dashboard,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _AgentDashboardHeader(
            properties: properties.length,
            leads: leads.length,
            appointments: appointments.length,
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: MediaQuery.sizeOf(context).width > 700 ? 4 : 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.18,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              DashboardMetricCard(
                icon: Icons.home_work,
                label: 'Properties',
                value: '${properties.length}',
                onTap: () => Navigator.pushNamed(context, AppRoutes.properties),
              ),
              DashboardMetricCard(
                icon: Icons.domain_add,
                label: 'Developments',
                value: '4',
                onTap: () => Navigator.pushNamed(context, AppRoutes.properties),
              ),
              DashboardMetricCard(
                icon: Icons.people,
                label: 'Leads',
                value: '${leads.length}',
                onTap: () => Navigator.pushNamed(context, AppRoutes.leads),
              ),
              DashboardMetricCard(
                icon: Icons.calendar_month,
                label: 'Viewings',
                value: '${appointments.length}',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.appointments),
              ),
            ],
          ),
          const SizedBox(height: 18),
          DashboardActionTile(
            icon: Icons.add_home,
            title: 'Add Property',
            subtitle: 'Create a listing and upload photos or videos',
            onTap: () => Navigator.pushNamed(context, AppRoutes.addProperty),
          ),
          DashboardActionTile(
            icon: Icons.home_work,
            title: 'Manage Properties',
            subtitle: 'Update prices, media, availability, and status',
            onTap: () => Navigator.pushNamed(context, AppRoutes.properties),
          ),
          DashboardActionTile(
            icon: Icons.people,
            title: 'Client Leads',
            subtitle: 'Review and capture buyer, seller, and tenant leads',
            onTap: () => Navigator.pushNamed(context, AppRoutes.leads),
          ),
          DashboardActionTile(
            icon: Icons.event_available,
            title: 'Viewing Schedule',
            subtitle: 'Manage property appointments and client viewings',
            onTap: () => Navigator.pushNamed(context, AppRoutes.appointments),
          ),
        ],
      ),
    );
  }
}

class _AgentDashboardHeader extends StatelessWidget {
  const _AgentDashboardHeader({
    required this.properties,
    required this.leads,
    required this.appointments,
  });

  final int properties;
  final int leads;
  final int appointments;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.navy,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Agent Dashboard',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage listings, leads, media, viewings, and rental application follow-ups from one place.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _AgentHeaderStat(label: 'Listings', value: '$properties'),
              _AgentHeaderStat(label: 'Leads', value: '$leads'),
              _AgentHeaderStat(label: 'Viewings', value: '$appointments'),
            ],
          ),
        ],
      ),
    );
  }
}

class _AgentHeaderStat extends StatelessWidget {
  const _AgentHeaderStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.78),
            ),
          ),
        ],
      ),
    );
  }
}
