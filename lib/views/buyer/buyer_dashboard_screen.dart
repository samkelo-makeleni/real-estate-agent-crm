import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_theme.dart';
import '../../core/routes/app_routes.dart';
import '../../viewmodels/app_state_provider.dart';
import '../../widgets/about_bgn_section.dart';
import '../../widgets/bgn_logo.dart';
import '../../widgets/property_card.dart';

class BuyerDashboardScreen extends StatelessWidget {
  const BuyerDashboardScreen({super.key});

  static final _rentalApplicationUri = Uri.https('plusdrop.co', '/rent/self', {
    'channel': 'bgn_crm_app',
    'utm_source': 'bgn_crm_app',
    'utm_medium': 'app',
    'utm_campaign': 'rental_application',
  });

  @override
  Widget build(BuildContext context) {
    final properties = AppStateProvider.of(context).publicProperties;
    final featured = properties.take(2).toList();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 76,
        title: const BgnLogo(compact: true),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
            icon: const Icon(Icons.login),
            label: const Text('Agent Login'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          BuyerPropertySearchPanel(
            onSearch: () {
              Navigator.pushNamed(context, AppRoutes.buyerProperties);
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Explore before you view',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Review photos, videos, prices, and property details before booking a physical viewing.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.ink.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _BuyerQuickAction(
                icon: Icons.photo_library,
                title: 'Photos',
                subtitle: 'See property images',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.buyerProperties),
              ),
              _BuyerQuickAction(
                icon: Icons.play_circle,
                title: 'Videos',
                subtitle: 'Watch walkthroughs',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.buyerProperties),
              ),
              _BuyerQuickAction(
                icon: Icons.event_available,
                title: 'Viewings',
                subtitle: 'Request a booking',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.buyerProperties),
              ),
              _BuyerQuickAction(
                icon: Icons.assignment,
                title: 'Apply',
                subtitle: 'Rental application',
                onTap: () => _openRentalApplication(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Featured properties',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.buyerProperties);
                },
                child: const Text('View all'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (featured.isEmpty)
            const Card(
              child: ListTile(
                leading: Icon(Icons.home_work_outlined),
                title: Text('No properties available yet'),
              ),
            )
          else
            for (final property in featured) ...[
              PropertyCard(
                property: property,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.propertyDetails,
                    arguments: property.id,
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          const SizedBox(height: 16),
          AboutBgnSection(
            onReadMore: () =>
                Navigator.pushNamed(context, AppRoutes.buyerProperties),
            onEnquire: () => Navigator.pushNamed(context, AppRoutes.addLead),
          ),
        ],
      ),
    );
  }

  static Future<void> _openRentalApplication(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final didLaunch = await launchUrl(
      _rentalApplicationUri,
      mode: LaunchMode.externalApplication,
    );

    if (!didLaunch) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not open rental application link')),
      );
    }
  }
}

class BuyerPropertySearchPanel extends StatelessWidget {
  const BuyerPropertySearchPanel({super.key, required this.onSearch});

  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.navy,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Property Search',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 520;
                  final searchBox = TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search by area or ref #',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: (_) => onSearch(),
                  );
                  final modeBox = const _SearchSelectBox(
                    icon: Icons.sell,
                    label: 'Sales',
                  );
                  final optionsBox = const _SearchSelectBox(
                    icon: Icons.tune,
                    label: 'More options',
                  );
                  final button = FilledButton.icon(
                    onPressed: onSearch,
                    icon: const Icon(Icons.search),
                    label: const Text('Search'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                    ),
                  );

                  if (!isWide) {
                    return Column(
                      children: [
                        modeBox,
                        const SizedBox(height: 10),
                        searchBox,
                        const SizedBox(height: 10),
                        optionsBox,
                        const SizedBox(height: 10),
                        button,
                      ],
                    );
                  }

                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: modeBox),
                          const SizedBox(width: 10),
                          Expanded(flex: 2, child: searchBox),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: optionsBox),
                          const SizedBox(width: 10),
                          Expanded(child: button),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchSelectBox extends StatelessWidget {
  const _SearchSelectBox({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.navy),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w800),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(Icons.keyboard_arrow_down, size: 18),
        ],
      ),
    );
  }
}

class _BuyerQuickAction extends StatelessWidget {
  const _BuyerQuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 156,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: AppTheme.navy),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
