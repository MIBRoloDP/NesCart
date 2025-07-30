import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:neskart/product_detail.dart';

class WishlistPage extends StatefulWidget {
  final List<Map<String, dynamic>> wishlist;

  const WishlistPage({super.key, required this.wishlist});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  @override
  Widget build(BuildContext context) {
    final wishlist = widget.wishlist;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Wishlist"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () {
              setState(() {
                wishlist.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Wishlist cleared.')),
              );
            },
          ),
        ],
      ),
      body: wishlist.isEmpty
          ? const Center(child: Text("Your wishlist is empty"))
          : ListView.builder(
        itemCount: wishlist.length,
        itemBuilder: (context, index) {
          final item = wishlist[index];

          final imageString = item['image'] ?? '';
          final title = item['title'] ?? item['name'] ?? 'No Title';
          final price = item['price']?.toString() ?? '0';

          Widget imageWidget;
          try {
            if (imageString.isNotEmpty) {
              imageWidget = Image.memory(
                base64Decode(imageString),
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              );
            } else {
              imageWidget = const Icon(Icons.image_not_supported);
            }
          } catch (_) {
            imageWidget = const Icon(Icons.broken_image);
          }

          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              leading: imageWidget,
              title: Text(title),
              subtitle: Text("Price: Rs. $price"),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    wishlist.removeAt(index);
                  });
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailPage(product: item),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
