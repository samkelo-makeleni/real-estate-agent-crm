enum PropertyType { house, apartment, land, office }

enum PropertyStatus { available, sold, rented, pending }

class PropertyModel {
  const PropertyModel({
    required this.id,
    required this.title,
    required this.price,
    required this.location,
    required this.type,
    required this.bedrooms,
    required this.bathrooms,
    required this.parking,
    required this.description,
    required this.status,
    required this.agentId,
    required this.imageUrls,
    required this.videoUrls,
    required this.createdAt,
  });

  final String id;
  final String title;
  final double price;
  final String location;
  final PropertyType type;
  final int bedrooms;
  final int bathrooms;
  final int parking;
  final String description;
  final PropertyStatus status;
  final String agentId;
  final List<String> imageUrls;
  final List<String> videoUrls;
  final DateTime createdAt;

  PropertyModel copyWith({
    String? id,
    String? title,
    double? price,
    String? location,
    PropertyType? type,
    int? bedrooms,
    int? bathrooms,
    int? parking,
    String? description,
    PropertyStatus? status,
    String? agentId,
    List<String>? imageUrls,
    List<String>? videoUrls,
    DateTime? createdAt,
  }) {
    return PropertyModel(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      location: location ?? this.location,
      type: type ?? this.type,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      parking: parking ?? this.parking,
      description: description ?? this.description,
      status: status ?? this.status,
      agentId: agentId ?? this.agentId,
      imageUrls: imageUrls ?? this.imageUrls,
      videoUrls: videoUrls ?? this.videoUrls,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
