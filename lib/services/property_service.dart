import '../core/config/supabase_config.dart';
import '../models/property_model.dart';

class PropertyService {
  final List<PropertyModel> _properties = [];

  Future<void> refreshPublicProperties() async {
    if (!SupabaseConfig.isConfigured) return;

    final rows = await SupabaseConfig.client!
        .from('properties')
        .select()
        .eq('status', 'available')
        .order('created_at', ascending: false);

    _mergeProperties(rows.map(_propertyFromSupabase));
  }

  Future<void> refreshAgentProperties(String agentId) async {
    if (!SupabaseConfig.isConfigured) return;

    final rows = await SupabaseConfig.client!
        .from('properties')
        .select()
        .eq('agent_id', agentId)
        .order('created_at', ascending: false);

    _mergeProperties(rows.map(_propertyFromSupabase));
  }

  List<PropertyModel> watchPublicProperties() {
    return _properties
        .where((property) => property.status == PropertyStatus.available)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  PropertyModel? propertyById(String propertyId) {
    for (final property in _properties) {
      if (property.id == propertyId) return property;
    }
    return null;
  }

  List<PropertyModel> watchProperties(String agentId) {
    return _properties.where((property) => property.agentId == agentId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> upsertProperty(PropertyModel property) async {
    if (SupabaseConfig.isConfigured) {
      final saved = await _upsertPropertyInSupabase(property);
      _upsertPropertyInMemory(saved);
      return;
    }

    _upsertPropertyInMemory(property);
  }

  Future<void> deleteProperty(String propertyId) async {
    if (SupabaseConfig.isConfigured) {
      await SupabaseConfig.client!
          .from('properties')
          .delete()
          .eq('id', propertyId);
    }
    _properties.removeWhere((property) => property.id == propertyId);
  }

  Future<PropertyModel> _upsertPropertyInSupabase(
    PropertyModel property,
  ) async {
    final client = SupabaseConfig.client!;
    final profile = await client
        .from('profiles')
        .select('agency_id')
        .eq('id', property.agentId)
        .single();

    final values = {
      'agency_id': profile['agency_id'],
      'agent_id': property.agentId,
      'title': property.title,
      'price': property.price,
      'location': property.location,
      'type': property.type.name,
      'bedrooms': property.bedrooms,
      'bathrooms': property.bathrooms,
      'parking': property.parking,
      'description': property.description,
      'status': property.status.name,
      'image_urls': property.imageUrls,
      'video_urls': property.videoUrls,
      'published_at': property.status == PropertyStatus.available
          ? DateTime.now().toIso8601String()
          : null,
    };

    final isGeneratedLocalId = property.id.startsWith('property-');
    final row = isGeneratedLocalId
        ? await client.from('properties').insert(values).select().single()
        : await client
              .from('properties')
              .update(values)
              .eq('id', property.id)
              .select()
              .single();

    return _propertyFromSupabase(row);
  }

  void _mergeProperties(Iterable<PropertyModel> properties) {
    for (final property in properties) {
      _upsertPropertyInMemory(property);
    }
  }

  void _upsertPropertyInMemory(PropertyModel property) {
    final index = _properties.indexWhere((item) => item.id == property.id);
    if (index == -1) {
      _properties.add(property);
    } else {
      _properties[index] = property;
    }
  }

  PropertyModel _propertyFromSupabase(Map<String, dynamic> row) {
    return PropertyModel(
      id: row['id'] as String,
      title: row['title'] as String? ?? '',
      price: (row['price'] as num?)?.toDouble() ?? 0,
      location: row['location'] as String? ?? '',
      type: _propertyTypeFromSupabase(row['type'] as String?),
      bedrooms: (row['bedrooms'] as num?)?.toInt() ?? 0,
      bathrooms: (row['bathrooms'] as num?)?.toInt() ?? 0,
      parking: (row['parking'] as num?)?.toInt() ?? 0,
      description: row['description'] as String? ?? '',
      status: _propertyStatusFromSupabase(row['status'] as String?),
      agentId: row['agent_id'] as String? ?? '',
      imageUrls: _stringList(row['image_urls']),
      videoUrls: _stringList(row['video_urls']),
      createdAt:
          DateTime.tryParse(row['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  List<String> _stringList(Object? value) {
    if (value is List) {
      return value.whereType<String>().toList();
    }
    return const [];
  }

  PropertyType _propertyTypeFromSupabase(String? value) {
    return PropertyType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => PropertyType.house,
    );
  }

  PropertyStatus _propertyStatusFromSupabase(String? value) {
    return PropertyStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => PropertyStatus.available,
    );
  }
}
