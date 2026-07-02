import '../models/property_model.dart';

class PropertyService {
  final List<PropertyModel> _properties = [];

  List<PropertyModel> watchPublicProperties() {
    return List<PropertyModel>.of(_properties)
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
    final index = _properties.indexWhere((item) => item.id == property.id);
    if (index == -1) {
      _properties.add(property);
    } else {
      _properties[index] = property;
    }
  }

  Future<void> deleteProperty(String propertyId) async {
    _properties.removeWhere((property) => property.id == propertyId);
  }
}
