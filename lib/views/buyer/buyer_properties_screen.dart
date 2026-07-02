import 'package:flutter/material.dart';

import '../../core/constants/app_theme.dart';
import '../../core/routes/app_routes.dart';
import '../../models/property_model.dart';
import '../../viewmodels/app_state_provider.dart';
import '../../widgets/bgn_logo.dart';
import '../../widgets/property_card.dart';

class BuyerPropertiesScreen extends StatefulWidget {
  const BuyerPropertiesScreen({super.key});

  @override
  State<BuyerPropertiesScreen> createState() => _BuyerPropertiesScreenState();
}

class _BuyerPropertiesScreenState extends State<BuyerPropertiesScreen> {
  final _search = TextEditingController();
  PropertyType? _type;
  PropertyStatus? _status;
  RangeValues _priceRange = const RangeValues(0, 40000000);
  bool _favoritesOnly = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppStateProvider.of(context);
    final properties = app.publicProperties;
    final query = _search.text.trim().toLowerCase();
    final filtered = properties
        .where((property) => _matches(property, query))
        .where((property) => _type == null || property.type == _type)
        .where((property) => _status == null || property.status == _status)
        .where(
          (property) =>
              property.price >= _priceRange.start &&
              property.price <= _priceRange.end,
        )
        .where(
          (property) => !_favoritesOnly || app.isFavoriteProperty(property.id),
        )
        .toList();

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
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Text(
            'Find your next property',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Browse photos, videos, prices, and details before booking a viewing.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.ink.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 18),
          SearchBar(
            controller: _search,
            hintText: 'Search location, title, or property type',
            leading: const Icon(Icons.search),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Filters',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _type = null;
                            _status = null;
                            _priceRange = const RangeValues(0, 40000000);
                            _favoritesOnly = false;
                            _search.clear();
                          });
                        },
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      DropdownMenu<PropertyType?>(
                        width: 170,
                        label: const Text('Type'),
                        initialSelection: _type,
                        dropdownMenuEntries: [
                          const DropdownMenuEntry(
                            value: null,
                            label: 'Any type',
                          ),
                          for (final type in PropertyType.values)
                            DropdownMenuEntry(value: type, label: type.name),
                        ],
                        onSelected: (value) => setState(() => _type = value),
                      ),
                      DropdownMenu<PropertyStatus?>(
                        width: 170,
                        label: const Text('Status'),
                        initialSelection: _status,
                        dropdownMenuEntries: [
                          const DropdownMenuEntry(
                            value: null,
                            label: 'Any status',
                          ),
                          for (final status in PropertyStatus.values)
                            DropdownMenuEntry(
                              value: status,
                              label: status.name,
                            ),
                        ],
                        onSelected: (value) => setState(() => _status = value),
                      ),
                      FilterChip(
                        selected: _favoritesOnly,
                        avatar: const Icon(Icons.favorite_border),
                        label: const Text('Favourites'),
                        onSelected: (value) {
                          setState(() => _favoritesOnly = value);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Price up to R ${_priceRange.end.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  RangeSlider(
                    min: 0,
                    max: 40000000,
                    divisions: 40,
                    values: _priceRange,
                    labels: RangeLabels(
                      'R ${_priceRange.start.toStringAsFixed(0)}',
                      'R ${_priceRange.end.toStringAsFixed(0)}',
                    ),
                    onChanged: (value) {
                      setState(() => _priceRange = value);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          if (filtered.isEmpty)
            const Card(
              child: ListTile(
                leading: Icon(Icons.search_off),
                title: Text('No matching properties'),
                subtitle: Text('Try a different location or property type.'),
              ),
            )
          else
            for (final property in filtered) ...[
              PropertyCard(
                property: property,
                trailing: IconButton(
                  tooltip: app.isFavoriteProperty(property.id)
                      ? 'Remove favourite'
                      : 'Save favourite',
                  onPressed: () => app.toggleFavoriteProperty(property.id),
                  icon: Icon(
                    app.isFavoriteProperty(property.id)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: app.isFavoriteProperty(property.id)
                        ? Colors.redAccent
                        : null,
                  ),
                ),
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
        ],
      ),
    );
  }

  bool _matches(PropertyModel property, String query) {
    if (query.isEmpty) return true;
    return property.title.toLowerCase().contains(query) ||
        property.location.toLowerCase().contains(query) ||
        property.type.name.toLowerCase().contains(query) ||
        property.status.name.toLowerCase().contains(query);
  }
}
