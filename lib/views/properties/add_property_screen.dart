import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../core/routes/app_routes.dart';
import '../../core/utils/currency_formatters.dart';
import '../../models/property_model.dart';
import '../../viewmodels/app_state.dart';
import '../../viewmodels/app_state_provider.dart';
import '../../widgets/bgn_scaffold.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _price = TextEditingController();
  final _location = TextEditingController();
  final _bedrooms = TextEditingController(text: '3');
  final _bathrooms = TextEditingController(text: '2');
  final _parking = TextEditingController(text: '1');
  final _description = TextEditingController();
  final List<PlatformFile> _selectedImages = [];
  final List<PlatformFile> _selectedVideos = [];
  final List<String> _existingImageUrls = [];
  final List<String> _existingVideoUrls = [];
  PropertyType _type = PropertyType.house;
  PropertyStatus _status = PropertyStatus.available;
  String? _editingPropertyId;
  bool _loadedEditingProperty = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _title.dispose();
    _price.dispose();
    _location.dispose();
    _bedrooms.dispose();
    _bathrooms.dispose();
    _parking.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppStateProvider.of(context);
    _loadEditingProperty(context, app);
    final isEditing = _editingPropertyId != null;

    return BgnScaffold(
      currentRoute: AppRoutes.addProperty,
      title: isEditing ? 'Edit Property' : 'Add Property',
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomTextField(
              controller: _title,
              label: 'Property title',
              icon: Icons.title,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _price,
              label: 'Price (ZAR)',
              icon: Icons.payments,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _location,
              label: 'Location',
              icon: Icons.place,
            ),
            const SizedBox(height: 12),
            _EnumDropdown<PropertyType>(
              label: 'Property type',
              value: _type,
              values: PropertyType.values,
              onChanged: (value) => setState(() => _type = value),
            ),
            const SizedBox(height: 12),
            _EnumDropdown<PropertyStatus>(
              label: 'Property status',
              value: _status,
              values: PropertyStatus.values,
              onChanged: (value) => setState(() => _status = value),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _bedrooms,
                    label: 'Bedrooms',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    controller: _bathrooms,
                    label: 'Bathrooms',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _parking,
              label: 'Parking',
              icon: Icons.local_parking,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _description,
              label: 'Description',
              icon: Icons.notes,
              maxLines: 4,
            ),
            const SizedBox(height: 18),
            _MediaPickerCard(
              icon: Icons.photo_library,
              title: 'Property images',
              subtitle: _mediaSubtitle(
                existing: _existingImageUrls.length,
                selected: _selectedImages.length,
                empty: 'Add photos clients can review before a viewing',
                label: 'image',
              ),
              fileNames: [
                ..._existingImageUrls.map((url) => _shortMediaLabel(url)),
                ..._selectedImages.map((file) => file.name),
              ],
              onPick: _pickImages,
            ),
            const SizedBox(height: 12),
            _MediaPickerCard(
              icon: Icons.video_library,
              title: 'Property videos',
              subtitle: _mediaSubtitle(
                existing: _existingVideoUrls.length,
                selected: _selectedVideos.length,
                empty: 'Add walkthrough videos or short room clips',
                label: 'video',
              ),
              fileNames: [
                ..._existingVideoUrls.map((url) => _shortMediaLabel(url)),
                ..._selectedVideos.map((file) => file.name),
              ],
              onPick: _pickVideos,
            ),
            const SizedBox(height: 18),
            CustomButton(
              label: isEditing ? 'Save changes' : 'Publish property',
              icon: isEditing ? Icons.save : Icons.cloud_upload,
              onPressed: _isSubmitting
                  ? null
                  : () async {
                      if (!_formKey.currentState!.validate()) return;
                      setState(() => _isSubmitting = true);
                      try {
                        if (isEditing) {
                          await app.updateProperty(
                            id: _editingPropertyId!,
                            title: _title.text.trim(),
                            price: CurrencyFormatters.parseRand(_price.text),
                            location: _location.text.trim(),
                            type: _type,
                            bedrooms: int.tryParse(_bedrooms.text) ?? 0,
                            bathrooms: int.tryParse(_bathrooms.text) ?? 0,
                            parking: int.tryParse(_parking.text) ?? 0,
                            description: _description.text.trim(),
                            status: _status,
                            existingImageUrls: _existingImageUrls,
                            existingVideoUrls: _existingVideoUrls,
                            imageFiles: _selectedImages,
                            videoFiles: _selectedVideos,
                          );
                        } else {
                          await app.addProperty(
                            title: _title.text.trim(),
                            price: CurrencyFormatters.parseRand(_price.text),
                            location: _location.text.trim(),
                            type: _type,
                            bedrooms: int.tryParse(_bedrooms.text) ?? 0,
                            bathrooms: int.tryParse(_bathrooms.text) ?? 0,
                            parking: int.tryParse(_parking.text) ?? 0,
                            description: _description.text.trim(),
                            status: _status,
                            imageFiles: _selectedImages,
                            videoFiles: _selectedVideos,
                          );
                        }
                        if (!context.mounted) return;
                        Navigator.pop(context);
                      } catch (error) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context)
                          ..clearSnackBars()
                          ..showSnackBar(
                            SnackBar(
                              content: Text(
                                'Could not ${isEditing ? 'save' : 'publish'} property: $error',
                              ),
                            ),
                          );
                      } finally {
                        if (mounted) {
                          setState(() => _isSubmitting = false);
                        }
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImages() async {
    final result = await FilePicker.pickFiles(type: FileType.image);
    if (result == null) return;
    setState(() {
      _selectedImages
        ..clear()
        ..addAll(result.files);
    });
  }

  Future<void> _pickVideos() async {
    final result = await FilePicker.pickFiles(type: FileType.video);
    if (result == null) return;
    setState(() {
      _selectedVideos
        ..clear()
        ..addAll(result.files);
    });
  }

  void _loadEditingProperty(BuildContext context, AppState app) {
    if (_loadedEditingProperty) return;
    _loadedEditingProperty = true;
    final propertyId = ModalRoute.of(context)?.settings.arguments as String?;
    if (propertyId == null) return;
    final property = app.propertyById(propertyId);
    if (property == null) return;
    _editingPropertyId = property.id;
    _title.text = property.title;
    _price.text = CurrencyFormatters.randInput(property.price);
    _location.text = property.location;
    _bedrooms.text = property.bedrooms.toString();
    _bathrooms.text = property.bathrooms.toString();
    _parking.text = property.parking.toString();
    _description.text = property.description;
    _type = property.type;
    _status = property.status;
    _existingImageUrls
      ..clear()
      ..addAll(property.imageUrls);
    _existingVideoUrls
      ..clear()
      ..addAll(property.videoUrls);
  }

  String _mediaSubtitle({
    required int existing,
    required int selected,
    required String empty,
    required String label,
  }) {
    final total = existing + selected;
    if (total == 0) return empty;
    return '$total $label file(s) attached';
  }

  String _shortMediaLabel(String url) {
    if (url.length <= 34) return url;
    return '${url.substring(0, 31)}...';
  }
}

class _MediaPickerCard extends StatelessWidget {
  const _MediaPickerCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.fileNames,
    required this.onPick,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> fileNames;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(icon),
              title: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(subtitle),
              trailing: OutlinedButton.icon(
                onPressed: onPick,
                icon: const Icon(Icons.upload_file),
                label: const Text('Select'),
              ),
            ),
            if (fileNames.isNotEmpty) ...[
              const Divider(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final name in fileNames.take(6))
                    Chip(
                      avatar: Icon(icon, size: 18),
                      label: Text(name, overflow: TextOverflow.ellipsis),
                    ),
                  if (fileNames.length > 6)
                    Chip(label: Text('+${fileNames.length - 6} more')),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EnumDropdown<T extends Enum> extends StatelessWidget {
  const _EnumDropdown({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> values;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: values
          .map(
            (item) => DropdownMenuItem<T>(value: item, child: Text(item.name)),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}
