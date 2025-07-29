import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:neskart/cart.dart';
import 'package:neskart/Profile_page.dart';
import 'package:neskart/login_page.dart';
import 'package:neskart/product_detail.dart' show ProductDetailPage;
import 'package:neskart/splash_screen.dart';
import 'newz_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'bottom_nav.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class homepage extends StatefulWidget {

  const homepage({super.key});
  @override
  State<homepage> createState() => _homepageState();
}

class _homepageState extends State<homepage> {

  List<bool> isFavoriteList = [];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isFavorite = false;

  List<String> _items = List.generate(10, (index) => 'Item ${index + 1}');
  bool _isLoading = false;
  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(const Duration(seconds: 2)); // Simulate delay
    setState(() {
      _items = List.generate(
        10,
        (index) => 'Refreshed Item ${index + 1} - ${DateTime.now().second}',
      );
      _isLoading = false;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Data Refreshed!')));
  }

  int _currentPage = 0; // To manage the active pagination dot
  // List of dummy news articles to populate the PageView
  final List<NewsArticle> newsArticles = [
    NewsArticle(
      imageUrl:
          'https://images.unsplash.com/photo-1482049016688-2d3e1b311543?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8Zm9vZHxlbnwwfHwwfHx8MA%3D%3D',
      category: 'Food',
      dev: 'Crunch',
      timeAgo: '1 day ago',
      headline: 'Now Or Never',
      isVerified: true,
    ),
    NewsArticle(
      imageUrl:
          'https://plus.unsplash.com/premium_photo-1664201890484-a5f7109c8e56?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OXx8ZWNvbW1lcmNlfGVufDB8fDB8fHww',
      category: 'Saleee',
      dev: 'Sewa',
      timeAgo: '6 hours ago',
      headline: 'Shop Your Way Through',
      isVerified: true,
    ),
    NewsArticle(
      imageUrl:
          'https://images.unsplash.com/photo-1636115305669-9096bffe87fd?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8Z2FkZ2V0c3xlbnwwfHwwfHx8MA%3D%3D',
      category: 'Tech',
      dev: 'Device',
      timeAgo: '2 hours ago',
      headline: 'Inovation in You',
      isVerified: true,
    ),
    NewsArticle(
      imageUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSxbU3zq3s8f3PSHRNQubNowRwh5YO9aes8eA&',
      category: 'World',
      dev: 'BBC News',
      timeAgo: '2 hours ago',
      headline: 'Global leaders meet for climate summit',
      isVerified: false,
    ),
    NewsArticle(
      imageUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSxbU3zq3s8f3PSHRNQubNowRwh5YO9aes8eA&',
      category: 'World',
      dev: 'BBC News',
      timeAgo: '2 hours ago',
      headline: 'Global leaders meet for climate summit',
      isVerified: false,
    ),
  ];
  List<String> allItems = ['Dev'];
  List<String> filteredItems = [];
  @override
  void initState() {
    super.initState();
    filteredItems = allItems;

    SearchFocusNode.addListener((){
      setState(() {
        isFocused = SearchFocusNode.hasFocus;

      });
    });

    SearchController.addListener((){
      setState(() {

      });
    });
  }

  void _filterSearch(String query) {
    setState(() {
      filteredItems =
          allItems
              .where((item) => item.toLowerCase().contains(query.toLowerCase()))
              .toList();
    });
  }

  final List<Map<String, dynamic>> categories = [
    {'label': 'Phones', 'icon': Icons.phone_android},
    {'label': 'Food', 'icon': Icons.no_food},
    {'label': 'Audio', 'icon': Icons.electric_bike},
    {'label': 'Consoles', 'icon': Icons.sports_esports},
    {'label': 'Laptops', 'icon': Icons.laptop},
    {'label': 'Cameras', 'icon': Icons.photo_camera},
    {'label': 'Audio', 'icon': Icons.headphones},
    {'label': 'Furniture', 'icon': Icons.table_restaurant},
  ];

  final products = [
    {
      "title": "Moth Button Down",
      "price": "\$49",
      "oldPrice": "\$25",
      "image":
          "https://images.unsplash.com/photo-1696581545171-019b905efd69?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8bW90aCUyMGJ1dHRvbmRvd24lMjBzaGlydHxlbnwwfHwwfHx8MA%3D%3D",
      "discount": "-20%",
    },
    {
      "title": "Iphone 16 pro",
      "price": "\$800",
      "oldPrice": "\$1020",
      "image":
          "https://images.unsplash.com/photo-1727099820362-b5bd5cd5a075?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8aXBob25lJTIwMTYlMjBwcm98ZW58MHx8MHx8fDA%3D",
      "discount": "-30%",
    },
    {
      "title": "Iphone 16 pro",
      "price": "\$800",
      "oldPrice": "\$1020",
      "image":
          "https://images.unsplash.com/photo-1727099820362-b5bd5cd5a075?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8aXBob25lJTIwMTYlMjBwcm98ZW58MHx8MHx8fDA%3D",
      "discount": "-30%",
    },
    {
      "title": "Iphone 16 pro",
      "price": "\$800",
      "oldPrice": "\$1020",
      "image":
          "https://images.unsplash.com/photo-1727099820362-b5bd5cd5a075?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8aXBob25lJTIwMTYlMjBwcm98ZW58MHx8MHx8fDA%3D",
      "discount": "-30%",
    },
  ];
  int _selectedIndex = 0;
  final List<IconData> _icons = [Icons.home, Icons.message, Icons.person];
  final flashCategories = [
    "Shoes",
    "Fashion",
    "Sports",
    "Accesories",
    "Interiors",
    "Gadgets",
  ];
  final flashCategoriesImage = [
    "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8c2hvZXxlbnwwfHwwfHx8MA%3D%3D",
    "https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8c2hpcnR8ZW58MHx8MHx8fDA%3D",
    "https://plus.unsplash.com/premium_photo-1661868926397-0083f0503c07?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8Zm9vdGJhbGx8ZW58MHx8MHx8fDA%3D",
    "https://images.unsplash.com/photo-1640324227718-f997fe8e9478?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8YWNjZXNvcml8ZW58MHx8MHx8fDA%3D",
    "https://images.unsplash.com/photo-1564078516393-cf04bd966897?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8N3x8aW50ZXJpb3IlMjBkZXNpZ258ZW58MHx8MHx8fDA%3D",
    "https://images.unsplash.com/photo-1468495244123-6c6c332eeece?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OHx8Z2FkZ2V0c3xlbnwwfHwwfHx8MA%3D%3D",
  ];
  int _selected = 0;
  final List<Map<String, dynamic>> Dev = [
    {
      'label': 'For You',
      'icon': Icons.favorite,
      'widget': Container(
        color: Colors.blue[50],
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16.0),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite, size: 40, color: Colors.blueAccent),
            SizedBox(height: 8),
            Text("Personalized for You!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Discover items tailored to your preferences."),
          ],
        ),
      ),
      'products': [  {
        'image': 'asset/drag.jpg',
        'name': 'Customized T-Shirt\n"Your Design Here"',
        'currentPrice': '£25.00',
        'oldPrice': '£30.00',
        'isFavorite': false,
      },
        {
          'image': 'asset/drag.jpg',
          'name': 'Smart Water Bottle\nTemperature Tracking',
          'currentPrice': '£35.00',
          'oldPrice': '£40.00',
          'isFavorite': false,
        },], // No specific products for 'For You'
    },
    {
      'label': 'Hot',
      'icon': Icons.whatshot,
      'widget': Container( // Example: A simple "Hot Deals" card
        color: Colors.red[50],
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16.0),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.whatshot, size: 40, color: Colors.red),
            SizedBox(height: 8),
            Text("Hot Deals!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Limited-time offers and trending products."),
          ],
        ),
      ),
      'products': [  {
        'image': 'asset/drag.jpg',
        'name': '4K Smart TV\n55-inch Ultra HD',
        'currentPrice': '£499.00',
        'oldPrice': '£699.00',
        'isFavorite': false,
      },
        {
          'image': 'asset/drag.jpg',
          'name': 'Wireless Gaming Headset\nNoise Cancelling',
          'currentPrice': '£79.00',
          'oldPrice': '£100.00',
          'isFavorite': false,
        },],
    },
    {
      'label': 'Voucher',
      'icon': Icons.card_giftcard,
      'widget': Container( // Example: A simple "Voucher" card
        color: Colors.green[50],
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16.0),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.card_giftcard, size: 40, color: Colors.green),
            SizedBox(height: 8),
            Text("Grab Your Vouchers!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Discounts and special offers."),
          ],
        ),
      ),
      'products': [ {
        'image': 'asset/drag.jpg',
        'name': 'Coffee Maker\nEspresso Machine',
        'currentPrice': '£120.00',
        'oldPrice': '£150.00',
        'isFavorite': false,
      },
        {
          'image': 'asset/drag.jpg',
          'name': 'Electric Toothbrush\nSonicare Series',
          'currentPrice': '£45.00',
          'oldPrice': '£60.00',
          'isFavorite': false,
        },],
    },
    {
      'label': 'Bag',
      'icon': Icons.shopping_bag,
      'widget': Container( // Example: A simple "Bag" card
        color: Colors.purple[50],
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16.0),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag, size: 40, color: Colors.purple),
            SizedBox(height: 8),
            Text("Bags Collection", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Explore our latest bag designs."),
          ],
        ),
      ),
      'products': [ {
        'image': 'asset/drag.jpg',
        'name': 'Leather Backpack\nVintage Style',
        'currentPrice': '£85.00',
        'oldPrice': '£100.00',
        'isFavorite': false,
      },
        {
          'image': 'asset/drag.jpg',
          'name': 'Travel Duffle Bag\nWaterproof Design',
          'currentPrice': '£55.00',
          'oldPrice': '£70.00',
          'isFavorite': false,
        },],
    },
    {
      'label': 'Bikes',
      'icon': Icons.directions_bike,
      'widget': Container( // Example: A simple "Bike" card
        color: Colors.orange[50],
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16.0),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_bike, size: 40, color: Colors.orange),
            SizedBox(height: 8),
            Text("Bikes for Every Ride!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Find your perfect two-wheeler."),

          ],
        ),
      ),
      'products': [ {
        'image': 'asset/drag.jpg',
        'name': 'Mountain Bike\n21-Speed Shimano',
        'currentPrice': '£350.00',
        'oldPrice': '£420.00',
        'isFavorite': false,
      },
        {
          'image': 'asset/drag.jpg',
          'name': 'Electric Commuter Bike\nFoldable Design',
          'currentPrice': '£700.00',
          'oldPrice': '£850.00',
          'isFavorite': false,
        },],
    },
    {
      'label': 'Mobiles',
      'icon': Icons.smartphone,
      'widget': null, // No generic widget for Mobiles; will show product cards
      'products': [ // **This is where you put your product data specific to Mobiles**
        {
          'image': 'asset/dragon.png', // Ensure 'asset/dragon.png' is correctly specified and exists
          'name': 'Apple iPhone 15 Pro\n128GB Natural Titanium',
          'currentPrice': '£699.00',
          'oldPrice': '£739.00',
          'isFavorite': false,
        },
        {
          'image': 'asset/dragon.png',
          'name': 'Samsung Galaxy Buds Pro\nTrue Wireless Black',
          'currentPrice': '£69.00',
          'oldPrice': '£86.00',
          'isFavorite': false,
        },
        {
          'image': 'asset/dragon.png',
          'name': 'Google Pixel 8 Pro\n256GB Obsidian',
          'currentPrice': '£799.00',
          'oldPrice': '£899.00',
          'isFavorite': false,
        },
        // Add more mobile product data here
      ],
    },
  ];

  final PageController _pageController = PageController();
  int _currentPage1 = 0;
  final List<String> bannerTexts = [
    "Get Your\nSpecial Sale\nUp to 40%",
    "Summer\nExclusive Deal\nUp to 50%",
    "Limited\nTime Offer\nUp to 60%",
  ];
  final ScrollController _scrollController = ScrollController();
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
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 85,
        title: Padding(
          padding: const EdgeInsets.all(0.0),
          child: TextFormField(
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            controller: SearchController,
            focusNode: SearchFocusNode,
            decoration: InputDecoration(
              hintText: 'Search',
              hintStyle: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              prefixIcon: Icon(Icons.search, color: Colors.black,),

              suffixIcon: ( isFocused )
                  ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.black),
                onPressed: () {
                  SearchController.clear();
                  FocusScope.of(context).unfocus();
                },
              ) : null,
              filled: true,
              fillColor: Color(0xFFe8dfd4),

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: Colors.grey.shade900,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: Colors.white,
                  width: 2.0,
                ),
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => splashScreen()),
                );
              },
              icon: Icon(Icons.shopping_cart, color: Colors.white, size: 30),
            ),
          ),
        ],
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black, //Color(0xFF5F9EA0),
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.all(0.0),
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.grey),
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
                        padding: const EdgeInsets.all(4),
                        child: const Icon(Icons.camera_alt, size: 20),
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
              leading: const Icon(Icons.shopping_cart),
              title: const Text("Cart"),
              onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context)=>cart()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_call),
              title: const Text("Video"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Analytics"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () {},
            ),
          ],
        ),
      ),
      // Color(0xFFC77138)=goldishbrown
      body:
          GestureDetector(
            onTap: (){
              FocusScope.of(context).unfocus();
            },
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: Colors.black))
                : RefreshIndicator(
                  color: Colors.black,
                  onRefresh: _refreshData,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.vertical,
                    child: Padding(
                      padding: EdgeInsets.all(0.0),
                      child: Column(
                        children: [
                          // Container(
                          //   height: _bannerAd.size.height.toDouble(),
                          //   width: _bannerAd.size.width.toDouble(),
                          //   child: AdWidget(ad: _bannerAd),
                          // ),
                          Stack(
                            children: [
                              ClipPath(
                                clipper: BottomFlowClipper(),
                                child: Container(
                                  width: 500,
                                  height: 255,
                                  decoration: BoxDecoration(color: Colors.black),
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
                                              borderRadius: BorderRadius.circular(
                                                10,
                                              ),
                                            ),
                                            clipBehavior: Clip.antiAlias,
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 9,
                                            ),
                                            child: Stack(
                                              children: [
                                                // Background Image
                                                Image.network(
                                                  article.imageUrl,
                                                  fit: BoxFit.cover,
                                                  height: 250,
                                                  width: double.infinity,
                                                  errorBuilder: (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) {
                                                    return Container(
                                                      height: 250,
                                                      width: double.infinity,
                                                      color: Colors.grey[300],
                                                      child: const Center(
                                                        child: Text(
                                                          'Image not loaded',
                                                          style: TextStyle(
                                                            color: Colors.black54,
                                                          ),
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
                                                        Colors.black.withOpacity(
                                                          0.0,
                                                        ),
                                                        Colors.black.withOpacity(
                                                          0.7,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                // Content (Text and Tag)
                                                Positioned(
                                                  top: 16,
                                                  left: 16,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 5,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      article.category,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text(
                                                            article
                                                                .dev, // Use article's source
                                                            style:
                                                                const TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                          ),
                                                          const SizedBox(
                                                            width: 4,
                                                          ),
                                                          // Verified checkmark icon (conditionally displayed)
                                                          if (article.isVerified)
                                                            Icon(
                                                              Icons.check_circle,
                                                              color:
                                                                  Colors
                                                                      .blue[300], // Light blue for the checkmark
                                                              size: 16,
                                                            ),
                                                          const SizedBox(
                                                            width: 8,
                                                          ),
                                                          Text(
                                                            article
                                                                .timeAgo, // Use article's time ago
                                                            style: const TextStyle(
                                                              color:
                                                                  Colors
                                                                      .white70, // Slightly faded for timestamp
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Text(
                                                        article
                                                            .headline, // Use article's headline
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
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
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          width: 5,
                                          height: 5,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color:
                                                _currentPage == index
                                                    ? Colors.white
                                                    : Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 255,
                                  left: 16,
                                  right: 10,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Categories',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              'See all',
                                              style: TextStyle(
                                                color: Colors.blue,
                                              ),
                                            ),
                                            Icon(
                                              Icons.arrow_forward_ios,
                                              size: 12,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),

                                    // Horizontal Category List
                                    SizedBox(
                                      height: 100,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: categories.length,
                                        itemBuilder: (context, index) {
                                          final item = categories[index];
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              right: 16.0,
                                            ),
                                            child: Column(
                                              children: [
                                                Container(
                                                  width: 60,
                                                  height: 60,
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFFe8dfd4),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    item['icon'] as IconData,
                                                    size: 30,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(item['label'] as String),
                                              ],
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
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "",
                                      style: TextStyle(color: Colors.green),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 100,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: flashCategories.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        margin: EdgeInsets.only(right: 12),
                                        width: 140,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          color: Colors.grey.shade300,
                                          image: DecorationImage(
                                            image: NetworkImage(
                                              "${flashCategoriesImage[index]}?text=${flashCategories[index]}",
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        alignment: Alignment.bottomLeft,
                                        padding: EdgeInsets.all(8),
                                        child: Text(
                                          flashCategories[index],
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(height: 25),
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
                                SizedBox(height: 25),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Best Seller",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "See all",
                                      style: TextStyle(color: Colors.green),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                SizedBox(
                                  height: 230,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: products.length,
                                    itemBuilder: (context, index) {
                                      final product = products[index];
                                      return GestureDetector(
                                        onTap: (){
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailPage(product: product,)));
                                        },
                                        child: Container(
                                          width: 140,
                                          margin: EdgeInsets.only(right: 16),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Stack(
                                                children: [
                                                  Image.network(
                                                    product["image"]!,
                                                    height: 130,
                                                    width: 140,
                                                    fit: BoxFit.cover,
                                                  ),
                                                  Positioned(
                                                    top: 8,
                                                    left: 8,
                                                    child: Container(
                                                      padding: EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2,
                                                      ),
                                                      color: Colors.red,
                                                      child: Text(
                                                        product["discount"]!,
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 8,
                                                    right: 8,
                                                    child: GestureDetector(
                                                      onTap: (){},
                                                      child: Icon(
                                                        Icons.favorite_border,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      product["title"]!,
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.star,
                                                          size: 16,
                                                          color: Colors.amber,
                                                        ),
                                                        Text(
                                                          "4.8",
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 4),
                                                    Text(
                                                      product["oldPrice"]!,
                                                      style: TextStyle(
                                                        decoration:
                                                            TextDecoration
                                                                .lineThrough,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    Text(
                                                      product["price"]!,
                                                      style: TextStyle(
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

                                SizedBox(height: 20),
                              ],
                            ),
                          ),
                          //  SizedBox(
                          //   height: 220,
                          //   child: ListView.builder(
                          //     scrollDirection: Axis.horizontal,
                          //     itemCount: deals.length,
                          //     padding: const EdgeInsets.all(12),
                          //     itemBuilder: (context, index) {
                          //       final item = deals[index];
                          //       return Container(
                          //         width: 160,
                          //         margin: const EdgeInsets.only(right: 12),
                          //         decoration: BoxDecoration(
                          //           color: Colors.white,
                          //           borderRadius: BorderRadius.circular(12),
                          //           boxShadow: [
                          //             BoxShadow(
                          //               color: Colors.grey.withOpacity(0.2),
                          //               blurRadius: 6,
                          //               offset: const Offset(2, 4),
                          //             ),
                          //           ],
                          //         ),
                          //         child: Column(
                          //           crossAxisAlignment: CrossAxisAlignment.start,
                          //           children: [
                          //             ClipRRect(
                          //               borderRadius: const BorderRadius.vertical(
                          //                 top: Radius.circular(12),
                          //               ),
                          //               child: Image.network(
                          //                 item['image']!,
                          //                 height: 100,
                          //                 width: double.infinity,
                          //                 fit: BoxFit.cover,
                          //               ),
                          //             ),
                          //             Padding(
                          //               padding: const EdgeInsets.symmetric(
                          //                 horizontal: 8,
                          //                 vertical: 6,
                          //               ),
                          //               child: Column(
                          //                 crossAxisAlignment:
                          //                     CrossAxisAlignment.start,
                          //                 children: [
                          //                   Text(
                          //                     item['title']!,
                          //                     style: const TextStyle(
                          //                       fontWeight: FontWeight.bold,
                          //                       fontSize: 14,
                          //                     ),
                          //                   ),
                          //                   const SizedBox(height: 4),
                          //                   Text(
                          //                     item['price']!,
                          //                     style: const TextStyle(
                          //                       color: Colors.red,
                          //                       fontWeight: FontWeight.bold,
                          //                     ),
                          //                   ),
                          //                   if (item['offer']!.isNotEmpty)
                          //                     Text(
                          //                       item['offer']!,
                          //                       style: const TextStyle(
                          //                         color: Colors.green,
                          //                       ),
                          //                     ),
                          //                   if (item['rating']!.isNotEmpty)
                          //                     Row(
                          //                       children: [
                          //                         const Icon(
                          //                           Icons.star,
                          //                           size: 14,
                          //                           color: Colors.orange,
                          //                         ),
                          //                         const SizedBox(width: 4),
                          //                         Text(
                          //                           item['rating']!,
                          //                           style: const TextStyle(
                          //                             fontSize: 12,
                          //                           ),
                          //                         ),
                          //                       ],
                          //                     ),
                          //                 ],
                          //               ),
                          //             ),
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
                              itemCount: Dev.length,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              itemBuilder: (context, index) {
                                final category = Dev[index];
                                bool isSelected = _selected == index;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
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
                                          backgroundColor:
                                          isSelected
                                              ? Colors.black
                                              : const Color(0xFFe8dfd4), //Color(0xFFdbd1c6),
                                          child: Icon(
                                            Dev[index]['icon'] as IconData,
                                            color:
                                            isSelected
                                                ? const Color(0xFFe8dfd4)
                                                : Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          Dev[index]["label"].toString(),
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          Builder(
                            builder: (context) {
                              // Get the currently selected category data
                              final selectedCategory = Dev[_selected];
                              // Access the products list for the selected category
                              final List<Map<String, dynamic>> currentProducts = selectedCategory['products'] as List<Map<String, dynamic>>;
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
                                  return Card(
                                    margin: EdgeInsets.zero,
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    color: Color(0xFFe8dfd4),
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
                                                  child: Image.asset(
                                                    product['image'],
                                                    width: double.infinity, // Image fills width of card
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, error, stackTrace) {
                                                      return Container(
                                                        width: double.infinity,
                                                        color: Colors.grey[200],
                                                        child: Icon(Icons.broken_image, color: Colors.grey[400]),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 115,bottom: 20 ),
                                                child: Align(
                                                  child: IconButton(
                                                    icon: Icon(
                                                      product['isFavorite'] ? Icons.favorite : Icons.favorite_border,
                                                      size: 20,
                                                      color: product['isFavorite'] ? Colors.red : Colors.black,
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        // Toggle the 'isFavorite' status for ONLY THIS product
                                                        product['isFavorite'] = !product['isFavorite'];
                                                      });
                                                    },
                                                  ),

                                                ),
                                              ),
                                      ]
                                          ),
                                          // Product Image

                                          const SizedBox(height: 8), // Spacing between image and text
                                          // Product Details
                                          Text(
                                            product['name'],
                                            style: const TextStyle(
                                              fontSize: 14, // Slightly smaller font for grid
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute prices
                                            children: [
                                              Text(
                                                product['currentPrice'],
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              Text(
                                                product['oldPrice'],
                                                style: const TextStyle(
                                                  fontSize: 12, // Smaller old price
                                                  color: Colors.grey,
                                                  decoration: TextDecoration.lineThrough,
                                                ),
                                              ),
                                            ],
                                          ),
                                          // You can add "Add to Cart" button or other elements here
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          Container(
                            height: 300,
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

                                    return Card(
                                      margin: EdgeInsets.zero,
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      color: const Color(0xFFe8dfd4), // match top card background
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Stack(
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(8.0),
                                                  child: Container(
                                                    height: 100, // fixed height like top card
                                                    width: double.infinity,
                                                    color: Colors.grey[200],
                                                    child: Builder(
                                                      builder: (context) {
                                                        try {
                                                          if (data['image'] != null && data['image'] != "") {
                                                            return Image.memory(
                                                              base64Decode(data['image']),
                                                              fit: BoxFit.cover,
                                                              width: double.infinity,
                                                              height: double.infinity,
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
                                                Stack(
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius: BorderRadius.circular(8.0),
                                                      child: Container(
                                                        height: 100,
                                                        width: double.infinity,
                                                        color: Colors.grey[200],
                                                        child: Builder(
                                                          builder: (context) {
                                                            try {
                                                              if (data['image'] != null && data['image'] != "") {
                                                                return Image.memory(
                                                                  base64Decode(data['image']),
                                                                  fit: BoxFit.cover,
                                                                  width: double.infinity,
                                                                  height: double.infinity,
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
                                                    // Favorite Icon Here
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
                                                            });
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ],
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
                                            // ElevatedButton(
                                            //   onPressed: () => addToCart(data),
                                            //   style: ElevatedButton.styleFrom(
                                            //     foregroundColor: Colors.white,
                                            //     backgroundColor: Colors.deepPurpleAccent,
                                            //     shape: RoundedRectangleBorder(
                                            //       borderRadius: BorderRadius.circular(8),
                                            //     ),
                                            //   ),
                                            //   child: const Text("Add To Cart"),
                                            // ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );

                              },
                            ),
                          ),
                          SizedBox(height: 200),
                        ],
                      ),
                    ),
                  ),
                ),
          ),

      // drawerScrimColor: Colors.transparent,
      // extendBody: true,
      // bottomNavigationBar: Padding(
      //   padding: const EdgeInsets.only(top: 700, bottom: 0),
      //   child: Center(
      //     child: Container(
      //       padding: const EdgeInsets.symmetric(horizontal: 1.5, vertical: 6.5),
      //       decoration: BoxDecoration(
      //         color: Colors.black, // translucent
      //         borderRadius: BorderRadius.circular(50),
      //       ),
      //       child: Row(
      //         mainAxisSize: MainAxisSize.min,
      //         children: List.generate(_icons.length, (index) {
      //           bool isSelected = _selectedIndex == index;
      //           return Padding(
      //             padding: const EdgeInsets.symmetric(horizontal: 6),
      //             child: InkWell(
      //               onTap: () => setState(() => _selectedIndex = index),
      //               borderRadius: BorderRadius.circular(50),
      //               child: Container(
      //                 padding: const EdgeInsets.all(12),
      //                 decoration: BoxDecoration(
      //                   color:
      //                       isSelected
      //                           ? Colors.white
      //                           : Colors.black, //Color(0xFFdbd1c6),
      //                   shape: BoxShape.circle,
      //                 ),
      //                 child: Icon(
      //                   _icons[index],
      //                   color: isSelected ? Colors.black : Colors.white,
      //                 ),
      //               ),
      //             ),
      //           );
      //         }),
      //       ),
      //     ),
      //   ),
      //),
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
      size.width * 0.85, // Control point 1 X (pulls curve towards right)
      size.height, // Control point 1 Y (bottom edge)
      size.width * 0.5, // Mid-point X of the curve
      size.height * 0.9, // Mid-point Y (lower than start/end of curve)
    );
    path.quadraticBezierTo(
      size.width * 0.25, // Control point 2 X (pulls curve towards left)
      size.height * 0.8, // Control point 2 Y (higher than mid-point)
      0, // End point X of the curve (bottom-left)
      size.height *
          1.0, // End point Y (matches mid-point height, making it flow)
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
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 10), // Add vertical space between items
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
          // Left content
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
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: const Text("Shop Now"),
                ),
                const SizedBox(height: 16),
                // Dots inside the banner
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
          // Right image
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Image.asset(
              'asset/dragon.png',
              height: 220,
              width: 150,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}

