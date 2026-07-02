import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_theme.dart';
import '../../core/routes/app_routes.dart';
import '../../models/property_model.dart';
import '../../viewmodels/app_state_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/status_chip.dart';

class PropertyDetailsScreen extends StatelessWidget {
  const PropertyDetailsScreen({super.key});

  static final _whatsAppUri = Uri.parse(
    'https://wa.me/27734734767?text=Hi%20BGN%2C%20I%20am%20interested%20in%20a%20property%20listed%20in%20the%20app.',
  );
  static final _callUri = Uri.parse('tel:+27734734767');
  static final _rentalApplicationUri = Uri.https('plusdrop.co', '/rent/self', {
    'channel': 'bgn_crm_app',
    'utm_source': 'bgn_crm_app',
    'utm_medium': 'app',
    'utm_campaign': 'rental_application',
  });

  @override
  Widget build(BuildContext context) {
    final propertyId = ModalRoute.of(context)?.settings.arguments as String?;
    final property = propertyId == null
        ? null
        : AppStateProvider.of(context).propertyById(propertyId);
    final app = AppStateProvider.of(context);

    if (property == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Property')),
        body: const Center(child: Text('Property not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(property.title),
        actions: [
          IconButton(
            tooltip: app.isFavoriteProperty(property.id)
                ? 'Remove favourite'
                : 'Save favourite',
            onPressed: () => app.toggleFavoriteProperty(property.id),
            icon: Icon(
              app.isFavoriteProperty(property.id)
                  ? Icons.favorite
                  : Icons.favorite_border,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _HeroMedia(property: property),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(property.location),
                  ],
                ),
              ),
              StatusChip(
                label: property.status.name,
                color: _statusColor(property.status),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'R ${property.price.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.navy,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _Feature(icon: Icons.bed, text: '${property.bedrooms} bed'),
              _Feature(icon: Icons.bathtub, text: '${property.bathrooms} bath'),
              _Feature(icon: Icons.garage, text: '${property.parking} parking'),
              _Feature(icon: Icons.home_work, text: property.type.name),
              _Feature(
                icon: Icons.photo_library,
                text: '${property.imageUrls.length} photos',
              ),
              _Feature(
                icon: Icons.video_library,
                text: '${property.videoUrls.length} videos',
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            property.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
          const SizedBox(height: 22),
          CustomButton(
            label: 'Enquire about this property',
            icon: Icons.mark_email_unread,
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.addLead,
                arguments: property.id,
              );
            },
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.bookAppointment,
                arguments: property.id,
              );
            },
            icon: const Icon(Icons.event_available),
            label: const Text('Book a viewing'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => _openRentalApplication(context),
            icon: const Icon(Icons.assignment),
            label: const Text('Apply to rent online'),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _launchContact(context, _whatsAppUri),
                  icon: const Icon(Icons.chat),
                  label: const Text('WhatsApp'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _launchContact(context, _callUri),
                  icon: const Icon(Icons.call),
                  label: const Text('Call agent'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _MediaList(property: property),
        ],
      ),
    );
  }

  static Future<void> _openRentalApplication(BuildContext context) async {
    await _launchContact(context, _rentalApplicationUri);
  }

  static Future<void> _launchContact(BuildContext context, Uri uri) async {
    final messenger = ScaffoldMessenger.of(context);
    final didLaunch = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!didLaunch) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
    }
  }

  Color _statusColor(PropertyStatus status) {
    return switch (status) {
      PropertyStatus.available => const Color(0xFF087F5B),
      PropertyStatus.pending => const Color(0xFFB7791F),
      PropertyStatus.sold => const Color(0xFF2B6CB0),
      PropertyStatus.rented => const Color(0xFF6B46C1),
    };
  }
}

class _HeroMedia extends StatelessWidget {
  const _HeroMedia({required this.property});

  final PropertyModel property;

  @override
  Widget build(BuildContext context) {
    final imageUrl = property.imageUrls
        .where((url) => url.startsWith('http://') || url.startsWith('https://'))
        .firstOrNull;

    return AspectRatio(
      aspectRatio: 16 / 10,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: imageUrl == null
            ? ColoredBox(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: const Icon(Icons.apartment, size: 52),
              )
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) {
                  return ColoredBox(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: const Icon(Icons.apartment, size: 52),
                  );
                },
              ),
      ),
    );
  }
}

class _MediaList extends StatelessWidget {
  const _MediaList({required this.property});

  final PropertyModel property;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Media',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            if (property.imageUrls.isEmpty && property.videoUrls.isEmpty)
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.perm_media_outlined),
                title: Text('No media uploaded yet'),
              ),
            for (final imageUrl in property.imageUrls)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.image),
                title: const Text('Photo'),
                subtitle: Text(
                  imageUrl,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            for (final videoUrl in property.videoUrls)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.play_circle),
                title: const Text('Video walkthrough'),
                subtitle: Text(
                  videoUrl,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(text),
      visualDensity: VisualDensity.compact,
    );
  }
}
