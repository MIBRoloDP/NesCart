import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:neskart/cart.dart';
import 'package:neskart/Profile_page.dart';
import 'package:neskart/login_page.dart';
import 'package:neskart/product_detail.dart' show ProductDetailPage;
import 'package:neskart/searchPage.dart';
import 'package:neskart/splash_screen.dart';

import 'package:neskart/wishlist.dart';

import 'package:neskart/vendor/admin_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'createProducts.dart';
import 'newz_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'bottom_nav.dart';

class homepage extends StatefulWidget {
  const homepage({super.key});
  @override
  State<homepage> createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _tabCategoriesKey = GlobalKey();
  List<bool> isFavoriteList = [];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isFavorite = false;

  List<String> _items = List.generate(10, (index) => 'Item ${index + 1}');
  bool _isLoading = false;


  List<Map<String, dynamic>> firebaseCategories = [];
  List<Map<String, dynamic>> firebaseProducts = [];
  List<Map<String, dynamic>> firebaseFlashCategories = [];
  List<Map<String, dynamic>> firebaseBestSellers = [];
  List<Map<String, dynamic>> firebaseTabCategories = [];
  List<Map<String, dynamic>> wishlist = [];
  bool isInWishlist(Map<String, dynamic> product) {
    return wishlist.any((item) => item['id'] == product['id']);
  }
  void removeFromWishlist(Map<String, dynamic> product) {
    setState(() {
      wishlist.removeWhere((item) => item['id'] == product['id']);
    });
  }
  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    await _loadFirebaseData();
    setState(() {
      _items = List.generate(
        10,(index) => 'Refreshed Item ${index + 1} - ${DateTime.now().second}',
      );
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data Refreshed!')),
    );
  }
  Future<void> _loadFirebaseData() async {
    try {
      final categoriesSnapshot = await _firestore.collection('categories').get();
      firebaseCategories = categoriesSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'label': data['name'] ?? 'Category',
          'icon': _getIconFromString(data['icon'] ?? 'phone_android'),
          ...data,
        };
      }).toList();


      final flashCategoriesSnapshot = await _firestore.collection('flash_categories').get();
      firebaseFlashCategories = flashCategoriesSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Flash Category',
          'image': data['image'] ?? '',
          ...data,
        };
      }).toList();
      final bestSellersSnapshot = await _firestore
          .collection('products')
          .where('isBestSeller', isEqualTo: true)
          .get();
      firebaseBestSellers = bestSellersSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'title': data['name'] ?? 'Product',
          'price': '\$${data['price'] ?? '0'}',
          'oldPrice': '\$${data['oldPrice'] ?? '0'}',
          'image': data['image'] ?? '',
          'discount': data['discount'] ?? '-0%',
          ...data,
        };
      }).toList();


      final tabCategoriesSnapshot = await _firestore.collection('tab_categories').get();
      firebaseTabCategories = [];
      for (var doc in tabCategoriesSnapshot.docs) {
        final data = doc.data();
        final productsSnapshot = await _firestore
            .collection('products')
            .where('categoryId', isEqualTo: doc.id)
            .get();
        final products = productsSnapshot.docs.map((productDoc) {
          final productData = productDoc.data();
          return {
            'id': productDoc.id,
            'image': productData['image'] ?? 'asset/drag.jpg',
            'name': productData['name'] ?? 'Product',
            'currentPrice': 'Rs ${productData['price'] ?? '0'}',
            'oldPrice': 'Rs ${productData['oldPrice'] ?? '0'}',
            'isFavorite': false,
            ...productData,
          };
        }).toList();
        firebaseTabCategories.add({
          'id': doc.id,
          'label': data['name'] ?? 'Category',
          'icon': _getIconFromString(data['icon'] ?? 'favorite'),
          'widget': _buildCategoryWidget(data['name'] ?? 'Category', data['description'] ?? ''),
          'products': products,
          ...data,
        });
      }
      setState(() {});
    } catch (e) {
      // print('Error loading Firebase data: $e');
    }
  }
  IconData _getIconFromString(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'phone_android':
        return Icons.phone_android;
      case 'no_food':
        return Icons.no_food;
      case 'electric_bike':
        return Icons.electric_bike;
      case 'sports_esports':
        return Icons.sports_esports;
      case 'laptop':
        return Icons.laptop;
      case 'photo_camera':
        return Icons.photo_camera;
      case 'headphones':
        return Icons.headphones;
      case 'table_restaurant':
        return Icons.table_restaurant;
      case 'favorite':
        return Icons.favorite;
      case 'whatshot':
        return Icons.whatshot;
      case 'card_giftcard':
        return Icons.card_giftcard;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'directions_bike':
        return Icons.directions_bike;
      case 'smartphone':
        return Icons.smartphone;
      default:
        return Icons.category;
    }
  }
  Widget _buildCategoryWidget(String title, String description) {
    final colors = [
      Colors.blue[50]!,
      Colors.red[50]!,
      Colors.green[50]!,
      Colors.purple[50]!,
      Colors.orange[50]!,
    ];
    final iconColors = [
      Colors.blueAccent,
      Colors.red,
      Colors.green,
      Colors.purple,
      Colors.orange,
    ];
    final icons = [
      Icons.favorite,
      Icons.whatshot,
      Icons.card_giftcard,
      Icons.shopping_bag,
      Icons.directions_bike,
    ];

    final index = title.length % colors.length;

    return Container(
      color: colors[index],
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icons[index], size: 40, color: iconColors[index]),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(description),
        ],
      ),
    );
  }
  int _currentPage = 0;
  final List<NewsArticle> newsArticles = [
    NewsArticle(
      imageUrl: 'https://images.unsplash.com/photo-1482049016688-2d3e1b311543?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8Zm9vZHxlbnwwfHwwfHx8MA%3D%3D',
      category: 'Food',
      dev: 'Crunch',
      timeAgo: '1 day ago',
      headline: 'Now Or Never',
      isVerified: true,
    ),
    NewsArticle(
      imageUrl: 'https://plus.unsplash.com/premium_photo-1664201890484-a5f7109c8e56?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OXx8ZWNvbW1lcmNlfGVufDB8fDB8fHww',
      category: 'Saleee',
      dev: 'Sewa',
      timeAgo: '6 hours ago',
      headline: 'Shop Your Way Through',
      isVerified: true,
    ),
    NewsArticle(
      imageUrl: 'https://images.unsplash.com/photo-1636115305669-9096bffe87fd?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8Z2FkZ2V0c3xlbnwwfHwwfHx8MA%3D%3D',
      category: 'Tech',
      dev: 'Device',
      timeAgo: '2 hours ago',
      headline: 'Innovation in You',
      isVerified: true,
    ),
    NewsArticle(
      imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSxbU3zq3s8f3PSHRNQubNowRwh5YO9aes8eA&',
      category: 'World',
      dev: 'News',
      timeAgo: '2 hours ago',
      headline: 'For Haul',
      isVerified: false,
    ),
  ];

  List<String> allItems = ['Dev'];
  List<String> filteredItems = [];

  @override
  void initState() {
    super.initState();
    filteredItems = allItems;
    _loadFirebaseData();

    SearchFocusNode.addListener(() {
      setState(() {
        isFocused = SearchFocusNode.hasFocus;
      });
    });

    SearchController.addListener(() {
      setState(() {});
    });
  }

  void _filterSearch(String query) {
    setState(() {
      filteredItems = allItems
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }
  int _selected = 0;
  final PageController _pageController = PageController();
  int _currentPage1 = 0;
  final List<String> bannerTexts = [
    "Get Your\nSpecial Sale\nUp to 30%",
    "Summer\nExclusive Deal\nDont Miss out",
    "Limited\nTime Offer",
  ];
  final TextEditingController SearchController = TextEditingController();
  final FocusNode SearchFocusNode = FocusNode();
  bool isFocused = false;
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
        .doc(product['name'] ?? product['title']);
    final existing = await cartRef.get();
    if (existing.exists) {
      final currentQty = existing.data()?['qty'] ?? 1;
      await cartRef.update({'qty': currentQty + 1});
    } else {
      await cartRef.set({
        'name': product['name'] ?? product['title'],
        'price': product['price'],
        'image': product['image'],
        'qty': 1,
        'isCheckout': false,
        'isDelivered': false,
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Added to cart!')),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 85,
        title: Container(
          width: MediaQuery.of(context).size.width/1.5,
          height: 50,

          child: GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>Searchpage()));
            },
            child: Card(
              color: Color(0xFFe8dfd4),
              child: Padding(
                padding: const EdgeInsets.only(top:12,left: 10),
                child: Text("Enter to Search",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,

                ),
                ),
              ),

            ),
          ),
        ),
        // Padding(
        //   padding: const EdgeInsets.all(0.0),
        //   child: GestureDetector(
        //     onTap: (){
        //
        //     },
        //     child: TextFormField(
        //       style: const TextStyle(
        //         color: Colors.black,
        //         fontWeight: FontWeight.bold,
        //       ),
        //       controller: SearchController,
        //       readOnly: true,
        //       focusNode: SearchFocusNode,
        //       decoration: InputDecoration(
        //         hintText: 'Search',
        //         hintStyle: const TextStyle(
        //           color: Colors.black,
        //           fontWeight: FontWeight.bold,
        //           fontSize: 16,
        //         ),
        //         prefixIcon: const Icon(Icons.search, color: Colors.black),
        //         suffixIcon: (isFocused)
        //             ? IconButton(
        //           icon: const Icon(Icons.clear, color: Colors.black),
        //           onPressed: () {
        //
        //             SearchController.clear();
        //             FocusScope.of(context).unfocus();
        //           },
        //         )
        //             : null,
        //         filled: true,
        //         fillColor: const Color(0xFFe8dfd4),
        //         enabledBorder: OutlineInputBorder(
        //           borderRadius: BorderRadius.circular(15),
        //           borderSide: BorderSide(
        //             color: Colors.grey.shade900,
        //             width: 1.5,
        //           ),
        //         ),
        //         focusedBorder: OutlineInputBorder(
        //           borderRadius: BorderRadius.circular(15),
        //           borderSide: const BorderSide(
        //             color: Colors.white,
        //             width: 2.0,
        //           ),
        //         ),
        //       ),
        //     ),
        //   ),
        // ),

        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: const EdgeInsets.all(0.0),
          children: [
             DrawerHeader(
              decoration: BoxDecoration(color: Colors.grey),
              child: Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('asset/dragon.png'),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white),
                        ),
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.camera_alt, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(

              leading: const Icon(Icons.list_alt_outlined),
              title: const Text("My Wishlist"),
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => WishlistPage(wishlist: wishlist)));


              },

            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () async{
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setBool("remember_me", false);
                Navigator.pop(context);

                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>splashScreen()));

              },
            ),
          ],
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.black))
            : RefreshIndicator(
          color: Colors.black,
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.vertical,
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: Column(
                children: [
                  Stack(
                    children: [
                      ClipPath(
                        clipper: BottomFlowClipper(),
                        child: Container(
                          width: 500,
                          height: 255,
                          decoration: const BoxDecoration(color: Colors.black),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 190,
                              width: 700,
                              child: PageView.builder(
                                itemCount: newsArticles.length,
                                onPageChanged: (index) {
                                  setState(() {
                                    _currentPage = index;
                                  });
                                },
                                itemBuilder: (context, index) {
                                  final article = newsArticles[index];
                                  return Card(
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    margin: const EdgeInsets.symmetric(horizontal: 9),
                                    child: Stack(
                                      children: [
                                        Image.network(
                                          article.imageUrl,
                                          fit: BoxFit.cover,
                                          height: 250,
                                          width: double.infinity,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              height: 250,
                                              width: double.infinity,
                                              color: Colors.grey[300],
                                              child: const Center(
                                                child: Text(
                                                  'Image not loaded',
                                                  style: TextStyle(color: Colors.black54),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        Container(
                                          height: 250,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.black.withOpacity(0.0),
                                                Colors.black.withOpacity(0.7),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 16,
                                          left: 16,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blue,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              article.category,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 16,
                                          left: 16,
                                          right: 16,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    article.dev,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  if (article.isVerified)
                                                    Icon(
                                                      Icons.check_circle,
                                                      color: Colors.blue[300],
                                                      size: 16,
                                                    ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    article.timeAgo,
                                                    style: const TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                article.headline,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                newsArticles.length,
                                    (index) => Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentPage == index ? Colors.white : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding:  EdgeInsets.only(top: 255, left: 16, right: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                 Text(
                                  'Categories',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                GestureDetector(
                                 onTap:  () {
                                   Scrollable.ensureVisible(
                                     _tabCategoriesKey.currentContext!,
                                     duration: const Duration(milliseconds: 500),
                                     curve: Curves.easeInOut,
                                   );
                                 },
                                  child: Row(
                                    children:  [
                                      Text(
                                        'See all',
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                      Icon(Icons.arrow_forward_ios, size: 12),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Firebase Categories
                            // SizedBox(
                            //   height: 100,
                            //   child: ListView.builder(
                            //     scrollDirection: Axis.horizontal,
                            //     itemCount: firebaseCategories.length,
                            //     itemBuilder: (context, index) {
                            //       final item = firebaseCategories[index];
                            //       return Padding(
                            //         padding: const EdgeInsets.only(right: 16.0),
                            //         child: Column(
                            //           children: [
                            //             Container(
                            //               width: 60,
                            //               height: 60,
                            //               decoration: const BoxDecoration(
                            //                 color: Color(0xFFe8dfd4),
                            //                 shape: BoxShape.circle,
                            //               ),
                            //               child: Icon(
                            //                 _getIconFromString(item['icon']),
                            //                 size: 30,
                            //                 color: Colors.black,
                            //               ),
                            //             ),
                            //             const SizedBox(height: 8),
                            //             Text(item['label'] as String),
                            //           ],
                            //         ),
                            //       );
                            //     },
                            //   ),
                            // ),
                            SizedBox(
                              height: 100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: firebaseCategories.length,

                                itemBuilder: (context, index) {
                                  final item = firebaseCategories[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 16.0),
                                    child: InkWell(
                                      onTap: () {

                                        switch (item['name']) {
                                          case 'Food':
                                            // Navigator.push(context, MaterialPageRoute(
                                            //   builder: (context) => cart(),
                                            // ));
                                            break; case 'Audio':
                                            // Navigator.push(context, MaterialPageRoute(
                                            //   builder: (context) => cart(),
                                            // ));
                                            break; case 'Furniture':
                                            // Navigator.push(context, MaterialPageRoute(
                                            //   builder: (context) => cart(),
                                            // ));
                                            break;
                                          case 'Device':
                                            // Navigator.push(context, MaterialPageRoute(
                                            //   builder: (context) => cart(),
                                            // ));
                                            break;
                                          case 'Discount':
                                            // Navigator.push(context, MaterialPageRoute(
                                            //   builder: (context) => LoginScreen(),
                                            // ));
                                          case 'Gaming':
                                            // Navigator.push(context, MaterialPageRoute(
                                            //   builder: (context) => LoginScreen(),
                                            // ));
                                            case 'Bike':
                                            // Navigator.push(context, MaterialPageRoute(
                                            //   builder: (context) => LoginScreen(),
                                            // ));
                                            break;
                                          default:
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('No page for ${item['label']}')),
                                            );
                                        }
                                      },
                                      child: Column(
                                        children: [
                                          Container(
                                            width: 60,
                                            height: 60,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFe8dfd4),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              _getIconFromString(item['icon']),
                                              size: 30,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(item['label'] as String),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text("", style: TextStyle(color: Colors.green)),
                          ],
                        ),
                        // Firebase Flash Categories
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: firebaseFlashCategories.length,
                            itemBuilder: (context, index) {
                              final category = firebaseFlashCategories[index];
                              return Container(
                                margin: const EdgeInsets.only(right: 12),
                                width: 140,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.grey.shade300,
                                  image: category['image'].isNotEmpty
                                      ? DecorationImage(
                                    image: MemoryImage(base64Decode(category['image'])),
                                    fit: BoxFit.cover,
                                  )
                                      : null,
                                ),
                                alignment: Alignment.bottomLeft,
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  category['name'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 25),
                        SizedBox(
                          height: 220,
                          child: PageView.builder(
                            scrollDirection: Axis.horizontal,
                            controller: _pageController,
                            itemCount: bannerTexts.length,
                            onPageChanged: (index) {
                              setState(() {
                                _currentPage1 = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              return SaleBanner(
                                text: bannerTexts[index],
                                index: index,
                                currentPage: _currentPage1,
                                totalPages: bannerTexts.length,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 25),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              "Best Seller",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text("See all", style: TextStyle(color: Colors.green)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Firebase Best Sellers
                        SizedBox(
                          height: 240,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: firebaseBestSellers.length,
                            itemBuilder: (context, index) {
                              final product = firebaseBestSellers[index];

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductDetailPage(product: product),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 150,
                                  margin: const EdgeInsets.only(right: 16),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(12),
                                    color: const Color(0xFFe8dfd4),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(12),
                                              topRight: Radius.circular(12),
                                            ),
                                            child: product['image'] != null && product['image'] != ""
                                                ? Image.memory(
                                              base64Decode(product["image"]),
                                              height: 130,
                                              width: 150,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  height: 130,
                                                  width: 150,
                                                  color: Colors.grey[300],
                                                  child: const Icon(Icons.broken_image),
                                                );
                                              },
                                            )
                                                : Container(
                                              height: 130,
                                              width: 150,
                                              color: Colors.grey[300],
                                              child: const Icon(Icons.image),
                                            ),
                                          ),
                                          if (product["discount"] != null && product["discount"].toString().isNotEmpty)
                                            Positioned(
                                              top: 8,
                                              left: 8,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  product["discount"].toString(),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: IconButton(
                                              icon: Icon(
                                                isInWishlist(product) ? Icons.favorite : Icons.favorite_border,
                                                color: isInWishlist(product) ? Colors.red : Colors.black,
                                                size: 20,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  if (isInWishlist(product)) {
                                                    wishlist.removeWhere((item) => item['id'] == product['id']);
                                                  } else {
                                                    wishlist.add(product);
                                                  }
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product["title"] ?? "Unnamed",
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            const Row(
                                              children: [
                                                Icon(Icons.star, size: 14, color: Colors.amber),
                                                SizedBox(width: 4),
                                                Text("4.8", style: TextStyle(fontSize: 12)),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "Rs ${product["oldPrice"] ?? '0'}",
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                                decoration: TextDecoration.lineThrough,
                                              ),
                                            ),
                                            Text(
                                              "Rs ${product["price"] ?? '0'}",
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  // Firebase Tab Categories
                  Container(
                    key:  _tabCategoriesKey,
                    child: SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: firebaseTabCategories.length,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemBuilder: (context, index) {
                          final category = firebaseTabCategories[index];
                          bool isSelected = _selected == index;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selected = index;
                                });
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: isSelected
                                        ? Colors.black
                                        : const Color(0xFFe8dfd4),
                                    child: Icon(
                                      _getIconFromString(category['icon']),
                                      color: isSelected
                                          ? const Color(0xFFe8dfd4)
                                          : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    category["label"].toString(),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Products Grid for Selected Category
                  Builder(
                    builder: (context) {
                      if (firebaseTabCategories.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              "Loading categories...",
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }

                      final selectedCategory = firebaseTabCategories[_selected];
                      final List<Map<String, dynamic>> currentProducts =
                      selectedCategory['products'] as List<Map<String, dynamic>>;

                      if (currentProducts.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              "No items available in this category yet.",
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: currentProducts.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 16.0,
                          childAspectRatio: 0.7,
                        ),
                        itemBuilder: (context, index) {
                          final product = currentProducts[index];

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailPage(product: product),
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
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8.0),
                                          child: Image.memory(
                                            base64Decode(product['image']),
                                            width: double.infinity,
                                            height: 160,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                width: double.infinity,
                                                height: 160,
                                                color: Colors.grey[200],
                                                child: Icon(
                                                  Icons.broken_image,
                                                  color: Colors.grey[400],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        Positioned(
                                          right: 0,
                                          top: 0,
                                          child: IconButton(
                                            icon: Icon(
                                              isInWishlist(product)
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              size: 20,
                                              color: isInWishlist(product)
                                                  ? Colors.red
                                                  : Colors.black,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                if (isInWishlist(product)) {
                                                  wishlist.removeWhere(
                                                          (item) => item['id'] == product['id']);
                                                } else {
                                                  wishlist.add(product);
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      product['name'] ?? "Unnamed",
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
                                          " ${product['currentPrice'] ?? '0'}",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          "Rs ${product['oldPrice'] ?? '0'}",
                                          style: const TextStyle(
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
                  Padding(
                    padding: EdgeInsets.only(right: 250,top: 20),
                    child: Text(
                      "All Products",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),

                  // Firebase Products Stream
                  Container(
                    height: 1650,
                    width: 400,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('products').snapshots(),
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
                                          Text(
                                          "Rs ${data['oldPrice'] ?? '0'}",
                                            style: const TextStyle(
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
                  const SizedBox(height: 200),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BottomFlowClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.8);
    path.quadraticBezierTo(
      size.width * 0.85,
      size.height,
      size.width * 0.5,
      size.height * 0.9,
    );
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.8,
      0,
      size.height * 1.0,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

class SaleBanner extends StatelessWidget {
  final String text;
  final int index;
  final int currentPage;
  final int totalPages;

  const SaleBanner({
    super.key,
    required this.text,
    required this.index,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFe8dfd4), Color(0xFFe8dfd4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),
                // ElevatedButton(
                //   onPressed: () {},
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: Colors.white,
                //     foregroundColor: Colors.black,
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(30),
                //     ),
                //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                //   ),
                //   child: const Text("Shop Now"),
                // ),
                const SizedBox(height: 16),
                Row(
                  children: List.generate(totalPages, (dotIndex) {
                    bool isActive = dotIndex == currentPage;
                    return Container(
                      margin: const EdgeInsets.only(right: 6),
                      width: isActive ? 20 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isActive ? Colors.white : Colors.grey[600],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  }),
                )
              ],
            ),
          ),
          const SizedBox(width: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: GestureDetector(
              onTap: (){
                // Navigator.push(context, MaterialPageRoute(builder: (context)=>()));
              },
              child: Image.network(
                'https://plus.unsplash.com/premium_photo-1701180529217-f2270f92f01f?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTE4fHxzYWxlfGVufDB8fDB8fHww',
                height: 200,
                width: 150,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return SizedBox(
                    height: 220,
                    width: 150,
                    child: Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return SizedBox(
                    height: 220,
                    width: 150,
                    child: Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}