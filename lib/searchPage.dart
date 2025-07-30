import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:neskart/product_detail.dart';

class Searchpage extends StatefulWidget {
  const Searchpage({super.key});

  @override
  State<Searchpage> createState() => _SearchpageState();
}

class _SearchpageState extends State<Searchpage> {
  final TextEditingController SearchController = TextEditingController();
  final FocusNode SearchFocusNode = FocusNode();
  bool isFocused = false;
  List<bool> isFavoriteList = [];
  List<Map<String, dynamic>> wishlist = [];
  Stream<QuerySnapshot> _searchStream() {
    final searchText = SearchController.text.trim();

    if (searchText.isEmpty) {
      return FirebaseFirestore.instance.collection('products').snapshots();
    }

    return FirebaseFirestore.instance
        .collection('products')
        .where('name', isGreaterThanOrEqualTo: searchText)
        .where('name', isLessThanOrEqualTo: searchText + '\uf8ff')
        .snapshots();
  }


  bool isInWishlist(Map<String, dynamic> product) {
    return wishlist.any((item) => item['id'] == product['id']);
  }

  void removeFromWishlist(Map<String, dynamic> product) {
    setState(() {
      wishlist.removeWhere((item) => item['id'] == product['id']);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 85,
        title:
        Padding(
          padding: const EdgeInsets.only(right: 40,top: 10,bottom: 10),
          child: TextFormField(
            onChanged: (value){
             setState(() {
               _searchStream();
             });
            },
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            controller: SearchController,
            focusNode: SearchFocusNode,
            decoration: InputDecoration(
              hintText: 'Enter to Search',
              hintStyle: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              suffixIcon: (isFocused)
                  ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.black),
                onPressed: () {

                  SearchController.clear();
                  FocusScope.of(context).unfocus();
                },
              )
                  : null,
              filled: true,
              fillColor: const Color(0xFFe8dfd4),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: Colors.grey.shade900,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Colors.white,
                  width: 2.0,
                ),
              ),
            ),
          ),
        ),

        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
      ),
      body:  SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: StreamBuilder<QuerySnapshot>(
          stream: _searchStream(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;
            if (isFavoriteList.length != docs.length) {
              isFavoriteList = List.generate(docs.length, (_) => false);
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.7,
              ),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;

                return GestureDetector(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailPage(product: data),
                      ),
                    );
                  },
                  child: Card(
                    margin: EdgeInsets.zero,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: const Color(0xFFe8dfd4),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Container(
                                    width: double.infinity,
                                    color: Colors.grey[200],
                                    child: Builder(
                                      builder: (context)
                                      {
                                        try {
                                          if (data['image'] != null && data['image'] != "") {
                                            return Image.memory(
                                              base64Decode(data['image']),
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height:160,
                                            );
                                          } else {
                                            return const Icon(Icons.image, size: 80);
                                          }
                                        } catch (e) {
                                          return const Icon(Icons.broken_image, size: 80);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 115, bottom: 20),
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: IconButton(
                                    icon: Icon(
                                      isFavoriteList[index] ? Icons.favorite : Icons.favorite_border,
                                      size: 20,
                                      color: isFavoriteList[index] ? Colors.red : Colors.black,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        isFavoriteList[index] = !isFavoriteList[index];

                                        final currentProduct = docs[index].data() as Map<String, dynamic>;

                                        if (isFavoriteList[index]) {
                                          // Add to wishlist if not already added
                                          if (!wishlist.any((item) => item['id'] == currentProduct['id'])) {
                                            wishlist.add(currentProduct);
                                          }
                                        } else {
                                          // Remove from wishlist
                                          wishlist.removeWhere((item) => item['id'] == currentProduct['id']);
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            data['name'] ?? "No Name",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Rs ${data['price'] ?? '0'}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const Text(
                                "Rs 00",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
