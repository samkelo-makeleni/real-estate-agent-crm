import 'package:flutter/material.dart';

import '../core/utils/currency_formatters.dart';
import '../models/property_model.dart';
import 'status_chip.dart';

class PropertyCard extends StatelessWidget {
  const PropertyCard({
    super.key,
    required this.property,
    this.onTap,
    this.trailing,
  });

  final PropertyModel property;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap ?? () => _showMediaSheet(context),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PropertyMediaPreview(property: property),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          property.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(property.location),
                        const SizedBox(height: 8),
                        Text(
                          CurrencyFormatters.rand(property.price),
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      StatusChip(
                        label: property.status.name,
                        color: _statusColor(property.status),
                      ),
                      if (trailing != null) ...[
                        const SizedBox(height: 6),
                        trailing!,
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _Feature(icon: Icons.bed, text: '${property.bedrooms} bed'),
                  _Feature(
                    icon: Icons.bathtub,
                    text: '${property.bathrooms} bath',
                  ),
                  _Feature(
                    icon: Icons.garage,
                    text: '${property.parking} parking',
                  ),
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
            ],
          ),
        ),
      ),
    );
  }

  void _showMediaSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              Text(
                property.title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              if (property.imageUrls.isEmpty && property.videoUrls.isEmpty)
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.perm_media_outlined),
                  title: Text('No property media uploaded yet'),
                ),
              for (final imageUrl in property.imageUrls)
                _MediaListTile(
                  icon: Icons.image,
                  title: 'Property photo',
                  subtitle: imageUrl,
                ),
              for (final videoUrl in property.videoUrls)
                _MediaListTile(
                  icon: Icons.play_circle,
                  title: 'Property video',
                  subtitle: videoUrl,
                ),
            ],
          ),
        );
      },
    );
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

class _PropertyMediaPreview extends StatelessWidget {
  const _PropertyMediaPreview({required this.property});

  final PropertyModel property;

  @override
  Widget build(BuildContext context) {
    final imageUrl = property.imageUrls
        .where((url) => url.startsWith('http://') || url.startsWith('https://'))
        .firstOrNull;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 72,
        height: 72,
        child: imageUrl == null
            ? ColoredBox(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: const Icon(Icons.apartment, size: 32),
              )
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) {
                  return ColoredBox(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: const Icon(Icons.apartment, size: 32),
                  );
                },
              ),
      ),
    );
  }
}

class _MediaListTile extends StatelessWidget {
  const _MediaListTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 4),
        Text(text),
      ],
    );
  }
}
