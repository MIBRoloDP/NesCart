import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neskart/bottom_nav.dart';
import 'package:neskart/cart.dart';
import 'package:neskart/orderpage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          "Profile Page",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () async {
                  try {
                    final file = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                    );

                    if (file == null) return;

                    setState(() {
                      imagePath = file.path;
                    });
                  } catch (e) {
                    debugPrint('Error picking image: $e');
                  }
                },
                child: ClipOval(
                  child: SizedBox(
                    width: 70,
                    height: 70,
                    child: ColoredBox(
                      color: Colors.grey[300]!,
                      child: imagePath != null
                          ? Image.file(
                        File(imagePath!),
                        fit: BoxFit.cover,
                      )
                          : Icon(
                        Icons.add_a_photo,
                        size: 30,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Dev Pradhan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(' ', style: TextStyle(fontSize: 12)),
                ],
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 24),

          // Orders
          const Text(
            'My Orders',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => OrderPage()),
                  );
                },
                child: Column(
                  children: const [
                    Icon(Icons.local_shipping, color: Colors.black),
                    SizedBox(height: 4),
                    Text('To Ship', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              Column(
                children: const [
                  Icon(Icons.reviews, color: Colors.black),
                  SizedBox(height: 4),
                  Text('To Review', style: TextStyle(fontSize: 12)),
                ],
              ),
              Column(
                children: const [
                  Icon(Icons.local_fire_department_outlined,
                      color: Colors.black),
                  SizedBox(height: 4),
                  Text('Hot', style: TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Promotion Cards
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFe8dfd4),
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Get Up to 70% OFF\nwith latest Offers!!!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => bottomnav()),
                          );
                        },
                        child: const Text(
                          'Explore',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFe8dfd4),
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Have Fun Shopping\nwith us!!!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => bottomnav()),
                          );
                        },
                        child: const Text(
                          'Shop Now',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // More Options
          const Text(
            'More Options',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Column(
                  children: const [
                    Icon(Icons.mail, size: 28),
                    SizedBox(height: 6),
                    Text("My Messages", style: TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => cart()));
                  },
                  child: Column(
                    children: const [
                      Icon(Icons.shopping_cart, size: 28),
                      SizedBox(height: 6),
                      Text("My Cart", style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  children: const [
                    Icon(Icons.support_agent, size: 28),
                    SizedBox(height: 6),
                    Text("Customer Care", style: TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(width: 20),
                Column(
                  children: const [
                    Icon(Icons.reviews, size: 28),
                    SizedBox(height: 6),
                    Text("My Reviews", style: TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(width: 20),
                Column(
                  children: const [
                    Icon(Icons.help, size: 28),
                    SizedBox(height: 6),
                    Text("Help Center", style: TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(width: 20),
                Column(
                  children: const [
                    Icon(Icons.payment, size: 27),
                    SizedBox(height: 6),
                    Text("My Payments", style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}