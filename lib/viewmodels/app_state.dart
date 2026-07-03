import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';

import '../core/config/supabase_config.dart';
import '../models/appointment_model.dart';
import '../models/lead_model.dart';
import '../models/property_model.dart';
import '../models/user_model.dart';
import '../services/appointment_service.dart';
import '../services/auth_service.dart';
import '../services/lead_service.dart';
import '../services/property_service.dart';
import '../services/storage_service.dart';

class AppState extends ChangeNotifier {
  AppState({
    required this.auth,
    required this.properties,
    required this.leads,
    required this.appointments,
    required this.storage,
  });

  final AuthService auth;
  final PropertyService properties;
  final LeadService leads;
  final AppointmentService appointments;
  final StorageService storage;

  bool _seeded = false;
  bool _initialized = false;
  bool _isInitializingBackend = false;
  final Set<String> _favoritePropertyIds = {};
  UserModel? get currentUser => auth.currentUser;
  bool get isInitializingBackend => _isInitializingBackend;

  List<PropertyModel> get agentProperties {
    final user = currentUser;
    if (user == null) return [];
    return properties.watchProperties(user.id);
  }

  List<PropertyModel> get publicProperties =>
      properties.watchPublicProperties();

  PropertyModel? propertyById(String propertyId) {
    return properties.propertyById(propertyId);
  }

  bool isFavoriteProperty(String propertyId) {
    return _favoritePropertyIds.contains(propertyId);
  }

  void toggleFavoriteProperty(String propertyId) {
    if (!_favoritePropertyIds.add(propertyId)) {
      _favoritePropertyIds.remove(propertyId);
    }
    notifyListeners();
  }

  List<LeadModel> get agentLeads {
    final user = currentUser;
    if (user == null) return [];
    return leads.watchLeads(user.id);
  }

  List<AppointmentModel> get agentAppointments {
    final user = currentUser;
    if (user == null) return [];
    return appointments.watchAppointments(user.id);
  }

  Future<void> login(String email, String password) async {
    await auth.signInWithEmail(email: email, password: password);
    await refreshProperties();
    notifyListeners();
  }

  Future<void> registerAgent({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    await auth.registerAgent(
      name: name,
      email: email,
      phone: phone,
      password: password,
    );
    notifyListeners();
  }

  Future<void> signOut() async {
    await auth.signOut();
    notifyListeners();
  }

  Future<void> refreshProperties() async {
    await properties.refreshPublicProperties();
    final user = currentUser;
    if (user != null) {
      await properties.refreshAgentProperties(user.id);
      await leads.refreshAgentLeads(user.id);
      await appointments.refreshAgentAppointments(user.id);
    }
  }

  Future<void> addProperty({
    required String title,
    required double price,
    required String location,
    required PropertyType type,
    required int bedrooms,
    required int bathrooms,
    required int parking,
    required String description,
    required PropertyStatus status,
    required List<PlatformFile> imageFiles,
    required List<PlatformFile> videoFiles,
  }) async {
    final user = currentUser;
    if (user == null) return;
    final imageUrls = await storage.uploadPropertyImages(imageFiles);
    final videoUrls = await storage.uploadPropertyVideos(videoFiles);
    await properties.upsertProperty(
      PropertyModel(
        id: 'property-${DateTime.now().microsecondsSinceEpoch}',
        title: title,
        price: price,
        location: location,
        type: type,
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        parking: parking,
        description: description,
        status: status,
        agentId: user.id,
        imageUrls: imageUrls,
        videoUrls: videoUrls,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  Future<void> updateProperty({
    required String id,
    required String title,
    required double price,
    required String location,
    required PropertyType type,
    required int bedrooms,
    required int bathrooms,
    required int parking,
    required String description,
    required PropertyStatus status,
    required List<String> existingImageUrls,
    required List<String> existingVideoUrls,
    required List<PlatformFile> imageFiles,
    required List<PlatformFile> videoFiles,
  }) async {
    final current = properties.propertyById(id);
    if (current == null) return;
    final imageUrls = [
      ...existingImageUrls,
      ...await storage.uploadPropertyImages(imageFiles),
    ];
    final videoUrls = [
      ...existingVideoUrls,
      ...await storage.uploadPropertyVideos(videoFiles),
    ];
    await properties.upsertProperty(
      current.copyWith(
        title: title,
        price: price,
        location: location,
        type: type,
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        parking: parking,
        description: description,
        status: status,
        imageUrls: imageUrls,
        videoUrls: videoUrls,
      ),
    );
    notifyListeners();
  }

  Future<void> addLead({
    required String clientName,
    required String phone,
    required String email,
    required String propertyId,
    required double budget,
    required String preferredLocation,
    required String notes,
  }) async {
    final user = currentUser;
    if (SupabaseConfig.isConfigured && user == null) return;
    await leads.addLead(
      LeadModel(
        id: 'lead-${DateTime.now().microsecondsSinceEpoch}',
        clientName: clientName,
        phone: phone,
        email: email,
        propertyId: propertyId,
        agentId: user?.id ?? 'agent-001',
        budget: budget,
        preferredLocation: preferredLocation,
        status: LeadStatus.newLead,
        notes: notes,
        createdAt: DateTime.now(),
      ),
    );
    if (user != null) {
      await leads.refreshAgentLeads(user.id);
    }
    notifyListeners();
  }

  Future<void> bookAppointment({
    required String propertyId,
    required String clientName,
    required DateTime dateTime,
    required String notes,
  }) async {
    final user = currentUser;
    if (SupabaseConfig.isConfigured && user == null) return;
    await appointments.bookAppointment(
      AppointmentModel(
        id: 'appointment-${DateTime.now().microsecondsSinceEpoch}',
        propertyId: propertyId,
        clientName: clientName,
        agentId: user?.id ?? 'agent-001',
        dateTime: dateTime,
        status: AppointmentStatus.booked,
        notes: notes,
      ),
    );
    if (user != null) {
      await appointments.refreshAgentAppointments(user.id);
    }
    notifyListeners();
  }

  void loadSeedData() {
    if (_seeded) return;
    _seeded = true;
    if (SupabaseConfig.isConfigured) {
      unawaited(startSignedOut());
      return;
    }

    properties.upsertProperty(
      PropertyModel(
        id: 'property-seed-1',
        title: 'Exclusive Atlantic Seaboard Villa',
        price: 34995000,
        location: 'Camps Bay, Cape Town',
        type: PropertyType.house,
        bedrooms: 5,
        bathrooms: 5,
        parking: 4,
        description:
            'Luxury mountainside residence with ocean views, entertainer terraces, and a pool.',
        status: PropertyStatus.available,
        agentId: 'agent-001',
        imageUrls: const [
          'https://www.bgnrealestate.co.za/images/hero-image.jpg',
        ],
        videoUrls: const [],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    );
    properties.upsertProperty(
      PropertyModel(
        id: 'property-seed-2',
        title: 'New Development Apartment',
        price: 4850000,
        location: 'Sea Point, Cape Town',
        type: PropertyType.apartment,
        bedrooms: 2,
        bathrooms: 2,
        parking: 1,
        description:
            'Modern lock-up-and-go apartment close to the promenade, restaurants, and schools.',
        status: PropertyStatus.pending,
        agentId: 'agent-001',
        imageUrls: const [
          'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688',
        ],
        videoUrls: const [],
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
      ),
    );
    leads.addLead(
      LeadModel(
        id: 'lead-seed-1',
        clientName: 'Naledi Jacobs',
        phone: '+27 82 555 0172',
        email: 'naledi@example.com',
        propertyId: 'property-seed-1',
        agentId: 'agent-001',
        budget: 35000000,
        preferredLocation: 'Atlantic Seaboard',
        status: LeadStatus.viewingBooked,
        notes:
            'Interested in luxury homes with views and private entertainment areas.',
        createdAt: DateTime.now().subtract(const Duration(hours: 9)),
      ),
    );
    appointments.bookAppointment(
      AppointmentModel(
        id: 'appointment-seed-1',
        propertyId: 'property-seed-1',
        clientName: 'Naledi Jacobs',
        agentId: 'agent-001',
        dateTime: DateTime.now().add(const Duration(days: 1, hours: 3)),
        status: AppointmentStatus.booked,
        notes: 'Prepare area report and comparable Atlantic Seaboard sales.',
      ),
    );
  }

  Future<void> startSignedOut() async {
    if (_initialized) return;
    _initialized = true;
    _isInitializingBackend = true;
    notifyListeners();
    try {
      await auth.signOut();
      await properties.refreshPublicProperties();
    } catch (error) {
      debugPrint('Could not start signed-out Supabase session: $error');
      await auth.signOut();
    } finally {
      _isInitializingBackend = false;
    }
    notifyListeners();
  }
}
