import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class EditProductPage extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> productData;

  const EditProductPage({
    super.key,
    required this.productId,
    required this.productData,
  });

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _oldPriceController;
  late TextEditingController _discountController;

  String? _selectedCategoryId;
  bool _isBestSeller = false;
  String? _base64Image;
  Uint8List? _imageBytes;

  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    final data = widget.productData;

    _nameController = TextEditingController(text: data['name'] ?? '');
    _priceController = TextEditingController(text: data['price']?.toString() ?? '');
    _oldPriceController = TextEditingController(text: data['oldPrice']?.toString() ?? '');
    _discountController = TextEditingController(text: data['discount'] ?? '');

    _selectedCategoryId = data['categoryId'];
    _isBestSeller = data['isBestSeller'] ?? false;
    _base64Image = data['image'];

    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final collections = {
      'tab_categories': 'Tabbed Categories',
      'flash_categories': 'Flash Categories',
      'categories': 'Categories',
    };

    List<Map<String, dynamic>> allItems = [];

    for (final entry in collections.entries) {
      final snapshot = await FirebaseFirestore.instance.collection(entry.key).get();

      // GroupD label (non-selectable)
      allItems.add({
        'isHeader': true,
        'label': entry.value,
      });

      // Add categories
      final items = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Unnamed',
          'source': entry.key,
          'isHeader': false,
        };
      }).toList();

      allItems.addAll(items);
    }

    setState(() {
      _categories = allItems;
    });
  }



  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _base64Image = base64Encode(bytes);
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final updatedData = {
      'name': _nameController.text.trim(),
      'price': double.tryParse(_priceController.text) ?? 0.0,
      'oldPrice': double.tryParse(_oldPriceController.text) ?? 0.0,
      'discount': _discountController.text.trim(),
      'categoryId': _selectedCategoryId,
      'isBestSeller': _isBestSeller,
    };

    if (_base64Image != null) {
      updatedData['image'] = _base64Image;
    }

    await FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productId)
        .update(updatedData);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFe8dfd4),
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        centerTitle: true,
        title: Text('Edit "${widget.productData['name']}"', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.black,
      ),
      body: _categories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.shopping_cart),
                  labelText: 'Product Name',
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              // Price + Old Price
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.attach_money),
                        labelText: 'Current Price',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _oldPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.money_off),
                        labelText: 'Old Price',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Discount
              TextFormField(
                controller: _discountController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.local_offer),
                  labelText: 'Discount (e.g., -20%)',
                ),
              ),
              const SizedBox(height: 12),

              // Image picker
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon:  Icon(Icons.image,color: Colors.black,),
                label:  Text('Change Product Image', style: TextStyle(
                  color: Colors.black,
                ),),
              ),
              if (_base64Image != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Image.memory(
                    base64Decode(_base64Image!),
                    height: 120,
                  ),
                ),

              const SizedBox(height: 8),

              // Category dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category),
                  labelText: 'Category',
                ),
                items: _categories.map((cat) {
                  if (cat['isHeader'] == true) {
                    return DropdownMenuItem<String>(
                      enabled: false,
                      child: Text(
                        cat['label'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }

                  return DropdownMenuItem<String>(
                    value: cat['id'],
                    child: Text(cat['name']),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => _selectedCategoryId = val);
                },
                validator: (val) => val == null ? 'Please select a category' : null,
              ),

              const SizedBox(height: 8),

              // Best Seller checkbox
              CheckboxListTile(
                title: const Text('Mark as Best Seller'),
                value: _isBestSeller,
                onChanged: (val) {
                  setState(() => _isBestSeller = val ?? false);
                },
              ),
              const SizedBox(height: 20),

              // Save button
              ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Save Product', style: TextStyle(
                  color: Colors.white,
                ),
               ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
