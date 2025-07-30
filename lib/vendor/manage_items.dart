import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neskart/vendor/edit_category.dart';
import 'package:neskart/vendor/edit_product.dart';

class ManageItemsScreen extends StatefulWidget {
  const ManageItemsScreen({super.key});

  @override
  State<ManageItemsScreen> createState() => _ManageItemsScreenState();
}

class _ManageItemsScreenState extends State<ManageItemsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String? _selectedCategory;

  final List<Tab> _tabs = const [
    Tab(text: 'Products'),
    Tab(text: 'Categories'),
    Tab(text: 'Flash Categories'),
    Tab(text: 'Tab Categories'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }


  Map<String, String> _categoryNameMap = {};

  Future<void> _loadCategories() async {
    final firestore = FirebaseFirestore.instance;
    final collections = ['categories', 'flash_categories', 'tab_categories'];

    final futures = collections.map((collection) async {
      final snap = await firestore.collection(collection).get();
      for (final doc in snap.docs) {
        final data = doc.data();
        _categoryNameMap[doc.id] = data['name'] ?? 'Unnamed';
      }
    });

    await Future.wait(futures);
  }



  Widget _buildProductsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: StreamBuilder<QuerySnapshot>(
            stream:
            FirebaseFirestore.instance.collection('categories').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              final categories = snapshot.data!.docs;
              return DropdownButtonFormField<String?>(
                decoration: const InputDecoration(
                  labelText: 'Filter by Category',
                  border: OutlineInputBorder(),
                ),
                value: _selectedCategory,
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All Categories'),
                  ),
                  ...categories.map((doc) {
                    final name = doc['name'] ?? 'Unnamed';
                    return DropdownMenuItem<String?>(
                      value: name,
                      child: Text(name),
                    );
                  }).toList(),
                ],
                onChanged: (val) => setState(() => _selectedCategory = val),
              );
            },
          ),
        ),
        Expanded(
          child: FutureBuilder(
            future: _loadCategories(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              return StreamBuilder<QuerySnapshot>(
                stream: (_selectedCategory == null)
                    ? FirebaseFirestore.instance.collection('products').snapshots()
                    : FirebaseFirestore.instance
                    .collection('products')
                    .where('category', isEqualTo: _selectedCategory)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final products = snapshot.data!.docs;

                  if (products.isEmpty) return const Center(child: Text('No products found.'));

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index].data() as Map<String, dynamic>;
                      final productId = products[index].id;

                      final categoryId = product['categoryId'];
                      final categoryName = _categoryNameMap[categoryId] ?? 'Uncategorized';

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          title: Text(product['name'] ?? 'Unnamed product'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('Price: Rs ${product['price'] ?? 'N/A'}'),
                              Text('Category: $categoryName'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditProductPage(
                                        productId: productId,
                                        productData: product,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Confirm Delete'),
                                      content: Text('Delete product "${product['name']}"?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx, true),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await FirebaseFirestore.instance
                                        .collection('products')
                                        .doc(productId)
                                        .delete();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        )

      ],
    );
  }

  Widget _buildCategoryTab(
      String collectionName, {
        List<String>? subtitleFields,
        Widget Function(Map<String, dynamic> data)? customSubtitle,
      }) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(collectionName).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;

        if (docs.isEmpty) return const Center(child: Text('No categories found.'));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final docId = docs[index].id;

            return Card(
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                title: Text(data['name'] ?? 'Unnamed category'),
                subtitle: customSubtitle != null
                    ? customSubtitle(data)
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: subtitleFields?.map((field) => Text('${data[field] ?? ''}')).toList() ?? [],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditCategoryPage(
                              collection: collectionName,
                              docId: docId,
                              data: data,
                            ),
                          ),
                        );
                      },
                    ),

                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Confirm Delete'),
                            content: Text('Delete category "${data['name']}"?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await FirebaseFirestore.instance
                              .collection(collectionName)
                              .doc(docId)
                              .delete();
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFe8dfd4),
      appBar: AppBar(
        title: const Text('Manage Products & Categories'),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProductsTab(),
          _buildCategoryTab('categories'),
          _buildCategoryTab(
            'flash_categories',
            customSubtitle: (data) {
              final imageData = data['image'];
              if (imageData == null) return const SizedBox();
              try {
                return Row(
                  children: [
                    Image.memory(
                      base64Decode(imageData),
                      height: 40,
                      width: 40,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: 8),
                    Text(data['name'] ?? ''),
                  ],
                );
              } catch (_) {
                return const Text('Invalid image');
              }
            },
          ),
          _buildCategoryTab('tab_categories', subtitleFields: ['description']),
        ],
      ),
    );
  }
}

