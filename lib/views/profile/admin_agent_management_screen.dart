import 'package:flutter/material.dart';

import '../../core/constants/app_theme.dart';
import '../../core/routes/app_routes.dart';
import '../../models/user_model.dart';
import '../../viewmodels/app_state_provider.dart';
import '../../widgets/bgn_scaffold.dart';

class AdminAgentManagementScreen extends StatefulWidget {
  const AdminAgentManagementScreen({super.key});

  @override
  State<AdminAgentManagementScreen> createState() =>
      _AdminAgentManagementScreenState();
}

class _AdminAgentManagementScreenState
    extends State<AdminAgentManagementScreen> {
  bool _isLoading = false;
  String? _updatingAgentId;
  String? _message;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAgents();
    });
  }

  Future<void> _loadAgents() async {
    final app = AppStateProvider.of(context);
    if (app.currentUser?.role != UserRole.admin) return;

    setState(() {
      _isLoading = true;
      _message = null;
    });
    try {
      await app.refreshAdminAgents();
    } catch (error) {
      _message = error.toString();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateRole(UserModel agent, UserRole role) async {
    if (agent.role == role) return;

    final app = AppStateProvider.of(context);
    setState(() {
      _updatingAgentId = agent.id;
      _message = null;
    });
    try {
      await app.updateAgentRole(agentId: agent.id, role: role);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(content: Text('${agent.name} is now ${_roleLabel(role)}.')),
        );
    } catch (error) {
      if (mounted) {
        setState(() => _message = error.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _updatingAgentId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppStateProvider.of(context);
    final currentUser = app.currentUser;
    final agents = app.adminAgents;
    final isAdmin = currentUser?.role == UserRole.admin;

    return BgnScaffold(
      currentRoute: AppRoutes.profile,
      title: 'Admin Agent Management',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!isAdmin)
            const _AdminAccessRequiredCard()
          else ...[
            _AdminSummaryCard(
              agents: agents,
              isLoading: _isLoading,
              onRefresh: _isLoading ? null : _loadAgents,
            ),
            if (_message != null) ...[
              const SizedBox(height: 12),
              _MessageBanner(message: _message!),
            ],
            const SizedBox(height: 12),
            if (_isLoading && agents.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (agents.isEmpty)
              const _EmptyAgentsCard()
            else
              for (final agent in agents) ...[
                _AgentManagementTile(
                  agent: agent,
                  isCurrentUser: agent.id == currentUser?.id,
                  isUpdating: _updatingAgentId == agent.id,
                  onRoleChanged: (role) => _updateRole(agent, role),
                ),
                const SizedBox(height: 10),
              ],
          ],
        ],
      ),
    );
  }
}

class _AdminSummaryCard extends StatelessWidget {
  const _AdminSummaryCard({
    required this.agents,
    required this.isLoading,
    required this.onRefresh,
  });

  final List<UserModel> agents;
  final bool isLoading;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final admins = agents.where((agent) => agent.role == UserRole.admin).length;
    final activeAgents = agents
        .where((agent) => agent.role == UserRole.agent)
        .length;
    final viewers = agents
        .where((agent) => agent.role == UserRole.viewer)
        .length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppTheme.navy.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings,
                    color: AppTheme.navy,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Agency Team',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh agents',
                  onPressed: onRefresh,
                  icon: isLoading
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _StatChip(
                  icon: Icons.groups,
                  label: 'Total',
                  value: agents.length,
                ),
                _StatChip(icon: Icons.shield, label: 'Admins', value: admins),
                _StatChip(
                  icon: Icons.real_estate_agent,
                  label: 'Agents',
                  value: activeAgents,
                ),
                _StatChip(
                  icon: Icons.visibility_outlined,
                  label: 'Viewers',
                  value: viewers,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text('$label: $value'),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _AgentManagementTile extends StatelessWidget {
  const _AgentManagementTile({
    required this.agent,
    required this.isCurrentUser,
    required this.isUpdating,
    required this.onRoleChanged,
  });

  final UserModel agent;
  final bool isCurrentUser;
  final bool isUpdating;
  final ValueChanged<UserRole> onRoleChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(child: Text(_initials(agent.name))),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              agent.name,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                          if (isCurrentUser) ...[
                            const SizedBox(width: 6),
                            const Chip(
                              visualDensity: VisualDensity.compact,
                              label: Text('You'),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        agent.email,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.ink.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<UserRole>(
                    initialValue: agent.role,
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      prefixIcon: Icon(Icons.manage_accounts),
                    ),
                    items: UserRole.values
                        .map(
                          (role) => DropdownMenuItem(
                            value: role,
                            child: Text(_roleLabel(role)),
                          ),
                        )
                        .toList(),
                    onChanged: isUpdating
                        ? null
                        : (role) {
                            if (role != null) onRoleChanged(role);
                          },
                  ),
                ),
                if (isUpdating) ...[
                  const SizedBox(width: 12),
                  const SizedBox.square(
                    dimension: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _roleDescription(agent.role),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.ink.withValues(alpha: 0.72),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'A';
    final first = parts.first.characters.first;
    final second = parts.length > 1 ? parts.last.characters.first : '';
    return (first + second).toUpperCase();
  }
}

class _AdminAccessRequiredCard extends StatelessWidget {
  const _AdminAccessRequiredCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.lock_outline, color: AppTheme.navy, size: 32),
            const SizedBox(height: 12),
            Text(
              'Admin access required',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Only admin users can view agency agents and change team roles.',
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyAgentsCard extends StatelessWidget {
  const _EmptyAgentsCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(18),
        child: ListTile(
          leading: Icon(Icons.group_off),
          title: Text('No agents found'),
          subtitle: Text('Refresh once agents have joined this agency.'),
        ),
      ),
    );
  }
}

class _MessageBanner extends StatelessWidget {
  const _MessageBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _roleLabel(UserRole role) {
  return switch (role) {
    UserRole.admin => 'Admin',
    UserRole.agent => 'Agent',
    UserRole.viewer => 'Viewer',
  };
}

String _roleDescription(UserRole role) {
  return switch (role) {
    UserRole.admin => 'Can manage agency users, listings, leads, and viewings.',
    UserRole.agent => 'Can manage assigned listings, leads, and viewings.',
    UserRole.viewer => 'Can review agency activity without management access.',
  };
}
