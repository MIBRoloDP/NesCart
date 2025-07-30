import 'package:flutter/material.dart';

import 'orderpage.dart';

class ModernProfilePage extends StatelessWidget {
  const ModernProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5,left: 1),
            child:  Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.only(top: 80, bottom: 30),
              child: Column(
                children: const [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('asset/dragon.png'),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Dev Pradhan',
                    style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.65,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xFFe8dfd4),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                        decoration: const BoxDecoration(
                          color: Color(0xFFe8dfd4),
                        ),
                        child:Column(
                          children: [

                            GestureDetector(
                              onTap: () {

                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(16),
                                    bottomRight: Radius.circular(16),
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(1, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: const [
                                    Icon(Icons.shopping_cart, color: Colors.black),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        'My Cart',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
                                  ],
                                ),
                              ),
                            ),

                            // My Orders
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) =>OrderPage()));
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(16),
                                    bottomRight: Radius.circular(16),
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(1, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: const [
                                    Icon(Icons.shopping_bag, color: Colors.black),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        'My Orders',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
                                  ],
                                ),
                              ),
                            ),

                          ],
                        ),

                      ),

                      SizedBox(height: 12),

                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOption({required IconData icon, required String label}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(1, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }
}
