import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class EditCategoryPage extends StatefulWidget {
  final String collection;
  final String docId;
  final Map<String, dynamic> data;

  const EditCategoryPage({
    super.key,
    required this.collection,
    required this.docId,
    required this.data,
  });

  @override
  State<EditCategoryPage> createState() => _EditCategoryPageState();
}

class _EditCategoryPageState extends State<EditCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  String? _selectedIcon;
  Uint8List? _selectedImage;
  String? _base64Image;

  final Map<String, IconData> _iconMap = {
    'phone_android': Icons.phone_android,
    'no_food': Icons.no_food,
    'electric_bike': Icons.electric_bike,
    'sports_esports': Icons.sports_esports,
    'laptop': Icons.laptop,
    'photo_camera': Icons.photo_camera,
    'headphones': Icons.headphones,
    'table_restaurant': Icons.table_restaurant,
    'favorite': Icons.favorite,
    'whatshot': Icons.whatshot,
    'card_giftcard': Icons.card_giftcard,
    'shopping_bag': Icons.shopping_bag,
    'directions_bike': Icons.directions_bike,
    'smartphone': Icons.smartphone,
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.data['name'] ?? '');
    _descriptionController =
        TextEditingController(text: widget.data['description'] ?? '');
    _selectedIcon = widget.data['icon'];
    if (widget.collection == 'flash_categories') {
      _base64Image = widget.data['image'];
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _selectedImage = bytes;
        _base64Image = base64Encode(bytes);
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final dataToUpdate = {
      'name': _nameController.text.trim(),
    };

    if (widget.collection == 'tab_categories') {
      dataToUpdate['description'] = _descriptionController.text.trim();
    }

    if (widget.collection == 'flash_categories') {
      if (_base64Image != null) dataToUpdate['image'] = _base64Image!;
    } else {
      dataToUpdate['icon'] = _selectedIcon!;
    }

    await FirebaseFirestore.instance
        .collection(widget.collection)
        .doc(widget.docId)
        .update(dataToUpdate);

    if (mounted) Navigator.pop(context);
  }


  String _formatCollectionName(String collection) { //For The Names in app bar since we have different format names in Firbase
    return collection
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Edit ${_formatCollectionName(widget.collection)}',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (val) => val == null || val.isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 16),
              if (widget.collection == 'tab_categories')
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
              if (widget.collection == 'flash_categories') ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image,color: Colors.black,),
                  label: const Text('Change Image', style: TextStyle(color: Colors.black),),
                ),
                if (_base64Image != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Image.memory(
                      base64Decode(_base64Image!),
                      height: 100,
                    ),
                  ),
              ] else ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedIcon,
                  decoration: const InputDecoration(labelText: 'Select Icon'),
                  items: _iconMap.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.key,
                      child: Row(
                        children: [
                          Icon(entry.value),
                          const SizedBox(width: 8),
                          Text(entry.key),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedIcon = val),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                child: const Text('Save Changes', style: TextStyle(color: Colors.white),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
