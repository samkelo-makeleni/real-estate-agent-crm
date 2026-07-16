import 'package:flutter/material.dart';

import '../../core/constants/app_theme.dart';
import '../../core/routes/app_routes.dart';
import '../../viewmodels/app_state_provider.dart';
import '../../widgets/bgn_scaffold.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppStateProvider.of(context);
    final user = app.currentUser;

    return BgnScaffold(
      currentRoute: AppRoutes.profile,
      title: 'Profile / Settings',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28,
                    child: Text(user?.name.characters.first ?? 'A'),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.name ?? 'Agent',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(user?.email ?? ''),
                  const SizedBox(height: 12),
                  Chip(
                    avatar: const Icon(Icons.verified_user, size: 18),
                    label: Text('Role: ${user?.role.name ?? 'agent'}'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const CompanyDetailsCard(),
          const SizedBox(height: 12),
          Card(
            child: SwitchListTile(
              value: app.notificationsEnabled,
              onChanged: (enabled) async {
                final accepted = await app.setPushNotificationsEnabled(enabled);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context)
                  ..clearSnackBars()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(
                        accepted
                            ? 'Viewing reminders are enabled.'
                            : 'Viewing reminders are disabled.',
                      ),
                    ),
                  );
              },
              secondary: const Icon(Icons.notifications_active),
              title: const Text('Push notifications'),
              subtitle: Text(
                'Viewing reminders ${app.viewingReminderMinutesBefore} minutes before appointments',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('Admin Agent Management'),
              subtitle: const Text('Ready for admin role workflows'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, AppRoutes.adminAgents),
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: () async {
              await app.signOut();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (_) => false,
              );
            },
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}

class CompanyDetailsCard extends StatelessWidget {
  const CompanyDetailsCard({super.key});

  static const _facts = [
    _CompanyFact(
      icon: Icons.business,
      label: 'Trading name',
      value: 'BGN Real Estate',
    ),
    _CompanyFact(
      icon: Icons.workspace_premium,
      label: 'Positioning',
      value:
          'Premium, selective, founder-led residential agency focused on sales, luxury rentals, rental management, developments, and advisory support.',
    ),
    _CompanyFact(
      icon: Icons.person,
      label: 'Leadership',
      value: 'Bavuyise Hermanus CA(SA), Managing Principal',
    ),
    _CompanyFact(
      icon: Icons.groups,
      label: 'Public team',
      value: 'One public agent profile currently listed.',
    ),
  ];

  static const _services = [
    'Residential sales',
    'Luxury rentals',
    'Rental management',
    'Developments and off-plan sales',
    'Investor and seller advisory',
  ];

  static const _verificationNotes = [
    'Ownership and incorporation date require a CIPC extract.',
    'Gauteng postcode differs across public sources; confirm before using on legal documents.',
    'Alternative public email info@bgnreal.co.za should be confirmed before publishing.',
    'BGN is described as operationally independent and strategically aligned with Black Pride Capital.',
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
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
                  child: const Icon(Icons.apartment, color: AppTheme.navy),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Company Details',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            for (final fact in _facts) ...[
              _CompanyFactRow(fact: fact),
              const SizedBox(height: 12),
            ],
            const Divider(height: 24),
            Text(
              'Services',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final service in _services)
                  Chip(
                    visualDensity: VisualDensity.compact,
                    label: Text(service),
                    avatar: const Icon(Icons.check_circle_outline, size: 18),
                  ),
              ],
            ),
            const Divider(height: 28),
            const _OfficeBlock(
              title: 'Gauteng Office',
              lines: [
                'Unit 230 San Ridge Village, Pavarotti Rd',
                'Carlswald, 1964',
              ],
              note: 'Public postcode should be confirmed.',
            ),
            const SizedBox(height: 12),
            const _OfficeBlock(
              title: 'East London Office',
              lines: ['14A Greenwood Street', 'Berea, 5241'],
            ),
            const Divider(height: 28),
            const _ContactRow(
              icon: Icons.call,
              label: 'Phone / WhatsApp',
              value: '+27 (0)73 473 4767',
            ),
            const SizedBox(height: 10),
            const _ContactRow(
              icon: Icons.email_outlined,
              label: 'Email',
              value: 'hermanusb@bgnrealestate.co.za',
            ),
            const Divider(height: 28),
            Text(
              'Verification Notes',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            for (final note in _verificationNotes) _VerificationNote(note),
            const SizedBox(height: 6),
            Text(
              'Website platform: web-box.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.ink.withValues(alpha: 0.66),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompanyFact {
  const _CompanyFact({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class _CompanyFactRow extends StatelessWidget {
  const _CompanyFactRow({required this.fact});

  final _CompanyFact fact;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(fact.icon, size: 22, color: AppTheme.navy),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fact.label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppTheme.ink.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 2),
              Text(fact.value, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class _OfficeBlock extends StatelessWidget {
  const _OfficeBlock({required this.title, required this.lines, this.note});

  final String title;
  final List<String> lines;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.location_on_outlined, color: AppTheme.navy),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              for (final line in lines) Text(line),
              if (note != null) ...[
                const SizedBox(height: 4),
                Text(
                  note!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.gold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.navy),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              SelectableText(value),
            ],
          ),
        ),
      ],
    );
  }
}

class _VerificationNote extends StatelessWidget {
  const _VerificationNote(this.note);

  final String note;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 18, color: AppTheme.gold),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              note,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.ink.withValues(alpha: 0.78),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
