import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? base64Image;
  Future<void> addToCart(Map<String, dynamic> product) async {

    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to add to cart')),
      );
      return;
    }

    final cartRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(product['name']);
    final existing = await cartRef.get();
    if (existing.exists) {
      final currentQty = existing.data()?['qty'] ?? 1;
      await cartRef.update({'qty': currentQty + 1});
    } else {
      await cartRef.set({
        'name': product['name'],
        'price': product['price'],
        'image': product['image'],
        'qty': 1,
        'isCheckout':false,
        'isDelivered':false,
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Added to cart!')),
    );
  }
  @override
  Widget build(BuildContext context) {

    final String imageUrl = widget.product['image'] ??
        'https://placehold.co/600x400/000000/FFFFFF?text=No+Image';
    final String title = widget.product['title'] ?? 'Product Name';
    final String price = widget.product['price'].toString() ?? '\$0.00';
    final String description = widget.product['description'] ??
        'Experience unmatched quality and style with this must-have item for your daily essentials.';

    return Scaffold(
      body: Stack(
        children: [

          Positioned.fill(
            child: Image.memory(
              base64Decode(imageUrl),
              fit: BoxFit.cover,
            ),
          ),


          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.6),
            ),
          ),


          Column(
            children: [
              const SizedBox(height: 50),


              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _circleButton(
                      icon: Icons.arrow_back,
                      onTap: () => Navigator.pop(context),
                    ),
                    _circleButton(
                      icon: Icons.favorite_border,
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),


              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Image.memory(
                    base64Decode(imageUrl),
                    height: 160,
                    width: 160,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.broken_image, size: 100);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ✅ Product Title & Price
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                price,
                style: const TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              // ✅ Rating Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return Icon(
                    index < 4 ? Icons.star : Icons.star_border,
                    color: Colors.orange,
                    size: 20,
                  );
                }),
              ),

              const SizedBox(height: 30),

              // ✅ Expanded Product Details Container
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Product Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                      ),
                      const Spacer(),

                      // ✅ Add to Cart Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                        onPressed: () => addToCart(widget.product),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Add to Cart',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onTap,
      ),
    );
  }
}
