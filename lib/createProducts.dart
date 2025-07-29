import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class AdminAddItemsPage extends StatefulWidget {
  const AdminAddItemsPage({super.key});

  @override
  State<AdminAddItemsPage> createState() => _AdminAddItemsPageState();
}

class _AdminAddItemsPageState extends State<AdminAddItemsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();


  final _categoryFormKey = GlobalKey<FormState>();
  final _flashCategoryFormKey = GlobalKey<FormState>();
  final _productFormKey = GlobalKey<FormState>();
  final _tabCategoryFormKey = GlobalKey<FormState>();


  final TextEditingController _categoryNameController = TextEditingController();
  String _selectedCategoryIcon = 'phone_android';


  final TextEditingController _flashCategoryNameController = TextEditingController();
  final TextEditingController _flashCategoryImageController = TextEditingController();
  XFile? _flashCategoryImageFile;


  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productPriceController = TextEditingController();
  final TextEditingController _productOldPriceController = TextEditingController();
  final TextEditingController _productDiscountController = TextEditingController();
  final TextEditingController _productImageController = TextEditingController();
  XFile? _productImageFile;
  bool _isBestSeller = false;
  String? _selectedCategoryId;
  List<Map<String, dynamic>> _availableCategories = [];

  final TextEditingController _tabCategoryNameController = TextEditingController();
  final TextEditingController _tabCategoryDescriptionController = TextEditingController();
  String _selectedTabCategoryIcon = 'favorite';

  bool _isLoading = false;


  final List<Map<String, dynamic>> _availableIcons = [
    {'name': 'phone_android', 'icon': Icons.phone_android, 'label': 'Phone'},
    {'name': 'no_food', 'icon': Icons.no_food, 'label': 'Food'},
    {'name': 'electric_bike', 'icon': Icons.electric_bike, 'label': 'Electric Bike'},
    {'name': 'sports_esports', 'icon': Icons.sports_esports, 'label': 'Gaming'},
    {'name': 'laptop', 'icon': Icons.laptop, 'label': 'Laptop'},
    {'name': 'photo_camera', 'icon': Icons.photo_camera, 'label': 'Camera'},
    {'name': 'headphones', 'icon': Icons.headphones, 'label': 'Audio'},
    {'name': 'table_restaurant', 'icon': Icons.table_restaurant, 'label': 'Furniture'},
    {'name': 'favorite', 'icon': Icons.favorite, 'label': 'Favorite'},
    {'name': 'whatshot', 'icon': Icons.whatshot, 'label': 'Hot'},
    {'name': 'card_giftcard', 'icon': Icons.card_giftcard, 'label': 'Voucher'},
    {'name': 'shopping_bag', 'icon': Icons.shopping_bag, 'label': 'Bag'},
    {'name': 'directions_bike', 'icon': Icons.directions_bike, 'label': 'Bike'},
    {'name': 'smartphone', 'icon': Icons.smartphone, 'label': 'Mobile'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadCategories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _categoryNameController.dispose();
    _flashCategoryNameController.dispose();
    _flashCategoryImageController.dispose();
    _productNameController.dispose();
    _productPriceController.dispose();
    _productOldPriceController.dispose();
    _productDiscountController.dispose();
    _productImageController.dispose();
    _tabCategoryNameController.dispose();
    _tabCategoryDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final snapshot = await _firestore.collection('tab_categories').get();
      setState(() {
        _availableCategories = snapshot.docs
            .map((doc) => {
          'id': doc.id,
          'name': doc.data()['name'] ?? 'Unnamed Category',
        })
            .toList();
      });
    } catch (e) {
      _showSnackBar('Error loading categories: $e', isError: true);
    }
  }

  Future<String?> _uploadImageToBase64(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      _showSnackBar('Error processing image: $e', isError: true);
      return null;
    }
  }

  Future<void> _pickImage({required bool isForFlashCategory}) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          if (isForFlashCategory) {
            _flashCategoryImageFile = image;
            _flashCategoryImageController.text = image.name;
          } else {
            _productImageFile = image;
            _productImageController.text = image.name;
          }
        });
      }
    } catch (e) {
      _showSnackBar('Error picking image: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _addCategory() async {
    if (!_categoryFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _firestore.collection('categories').add({
        'name': _categoryNameController.text.trim(),
        'icon': _selectedCategoryIcon,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _showSnackBar('Category added successfully!');
      _categoryNameController.clear();
      setState(() => _selectedCategoryIcon = 'phone_android');
    } catch (e) {
      _showSnackBar('Error adding category: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addFlashCategory() async {
    if (!_flashCategoryFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String? imageBase64;
      if (_flashCategoryImageFile != null) {
        imageBase64 = await _uploadImageToBase64(_flashCategoryImageFile!);
      }

      await _firestore.collection('flash_categories').add({
        'name': _flashCategoryNameController.text.trim(),
        'image': imageBase64 ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      _showSnackBar('Flash category added successfully!');
      _flashCategoryNameController.clear();
      _flashCategoryImageController.clear();
      setState(() => _flashCategoryImageFile = null);
    } catch (e) {
      _showSnackBar('Error adding flash category: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addProduct() async {
    if (!_productFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String? imageBase64;
      if (_productImageFile != null) {
        imageBase64 = await _uploadImageToBase64(_productImageFile!);
      }

      await _firestore.collection('products').add({
        'name': _productNameController.text.trim(),
        'price': double.tryParse(_productPriceController.text) ?? 0.0,
        'oldPrice': double.tryParse(_productOldPriceController.text) ?? 0.0,
        'discount': _productDiscountController.text.trim(),
        'image': imageBase64 ?? '',
        'isBestSeller': _isBestSeller,
        'categoryId': _selectedCategoryId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _showSnackBar('Product added successfully!');
      _clearProductForm();
    } catch (e) {
      _showSnackBar('Error adding product: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addTabCategory() async {
    if (!_tabCategoryFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _firestore.collection('tab_categories').add({
        'name': _tabCategoryNameController.text.trim(),
        'description': _tabCategoryDescriptionController.text.trim(),
        'icon': _selectedTabCategoryIcon,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _showSnackBar('Tab category added successfully!');
      _tabCategoryNameController.clear();
      _tabCategoryDescriptionController.clear();
      setState(() => _selectedTabCategoryIcon = 'favorite');
      await _loadCategories();
    } catch (e) {
      _showSnackBar('Error adding tab category: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearProductForm() {
    _productNameController.clear();
    _productPriceController.clear();
    _productOldPriceController.clear();
    _productDiscountController.clear();
    _productImageController.clear();
    setState(() {
      _productImageFile = null;
      _isBestSeller = false;
      _selectedCategoryId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - Add Items', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFe8dfd4),
          tabs: const [
            Tab(text: 'Categories'),
            Tab(text: 'Flash Categories'),
            Tab(text: 'Products'),
            Tab(text: 'Tab Categories'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoryForm(),
          _buildFlashCategoryForm(),
          _buildProductForm(),
          _buildTabCategoryForm(),
        ],
      ),
    );
  }

  Widget _buildCategoryForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _categoryFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add New Category',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _categoryNameController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter category name';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            const Text('Select Icon:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            Container(
              height: 120,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: _availableIcons.length,
                itemBuilder: (context, index) {
                  final iconData = _availableIcons[index];
                  final isSelected = _selectedCategoryIcon == iconData['name'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategoryIcon = iconData['name'];
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFe8dfd4) : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? Colors.black : Colors.grey,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(iconData['icon'], size: 24),
                          const SizedBox(height: 4),
                          Text(
                            iconData['label'],
                            style: const TextStyle(fontSize: 10),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _addCategory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Add Category'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlashCategoryForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _flashCategoryFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Flash Category',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _flashCategoryNameController,
              decoration: const InputDecoration(
                labelText: 'Flash Category Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.flash_on),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter flash category name';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _flashCategoryImageController,
              decoration: InputDecoration(
                labelText: 'Image',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.image),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.photo_library),
                  onPressed: () => _pickImage(isForFlashCategory: true),
                ),
              ),
              readOnly: true,
            ),
            if (_flashCategoryImageFile != null) ...[
              const SizedBox(height: 10),
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FutureBuilder<Uint8List>(
                  future: _flashCategoryImageFile!.readAsBytes(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          snapshot.data!,
                          fit: BoxFit.cover,
                        ),
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ],
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _addFlashCategory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Add Flash Category'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _productFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add New Product',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _productNameController,
              decoration: const InputDecoration(
                labelText: 'Product Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.shopping_cart),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter product name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _productPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Current Price',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter price';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter valid number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _productOldPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Old Price',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.money_off),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        if (double.tryParse(value) == null) {
                          return 'Please enter valid number';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _productDiscountController,
              decoration: const InputDecoration(
                labelText: 'Discount (e.g., -20%)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_offer),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter discount';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _productImageController,
              decoration: InputDecoration(
                labelText: 'Product Image',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.image),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.photo_library),
                  onPressed: () => _pickImage(isForFlashCategory: false),
                ),
              ),
              readOnly: true,
            ),
            if (_productImageFile != null) ...[
              const SizedBox(height: 10),
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FutureBuilder<Uint8List>(
                  future: _productImageFile!.readAsBytes(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          snapshot.data!,
                          fit: BoxFit.cover,
                        ),
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ],
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategoryId,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: _availableCategories.map((category) {
                return DropdownMenuItem<String>(
                  value: category['id'],
                  child: Text(category['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategoryId = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a category';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _isBestSeller,
                  onChanged: (value) {
                    setState(() {
                      _isBestSeller = value ?? false;
                    });
                  },
                ),
                const Text('Mark as Best Seller'),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _addProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Add Product'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabCategoryForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _tabCategoryFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Tab Category',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _tabCategoryNameController,
              decoration: const InputDecoration(
                labelText: 'Tab Category Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.tab),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter tab category name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tabCategoryDescriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter description';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            const Text('Select Icon:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            Container(
              height: 120,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: _availableIcons.length,
                itemBuilder: (context, index) {
                  final iconData = _availableIcons[index];
                  final isSelected = _selectedTabCategoryIcon == iconData['name'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTabCategoryIcon = iconData['name'];
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFe8dfd4) : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? Colors.black : Colors.grey,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(iconData['icon'], size: 24),
                          const SizedBox(height: 4),
                          Text(
                            iconData['label'],
                            style: const TextStyle(fontSize: 10),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _addTabCategory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Add Tab Category'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}