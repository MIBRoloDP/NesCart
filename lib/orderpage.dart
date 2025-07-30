import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:neskart/track_order.dart';
class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  int selectedIndex = 0;
  final tabs = ['Ongoing', 'Completed', 'Canceled'];
FirebaseAuth _auth = FirebaseAuth.instance;
  Stream<QuerySnapshot> getUserCart(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(uid).collection('cart').snapshots();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(body: StreamBuilder(
      stream: getUserCart(_auth.currentUser!.uid),
      builder: (context, cartSnapshot) {
        if (!cartSnapshot.hasData) return const CircularProgressIndicator();

        final cartItems = cartSnapshot.data!.docs
            .where((doc) => (doc.data() as Map)['isCheckout'])
            .toList();

        if (cartItems.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("No items in cart."),
          );
        }

        return ListView.builder(
          itemCount: cartItems.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final item = cartItems[index];
            final itemData = item.data() as Map<String, dynamic>;

            return GestureDetector(
              onTap: (){
                itemData['isCheckout']?Navigator.push(context, MaterialPageRoute(builder: (context)=>OrderTrackingMap(
                  orderId: itemData['orderDetails']['orderId'],
                ))):"";
              },
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: Image.memory(base64Decode(itemData['image']), width: 50, height: 50),
                  title: Text(itemData['name']),
                  subtitle: Text("Qty: ${itemData['qty']} • Rs.${itemData['price']}"),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(itemData['isCheckout'] ? "Checked Out" : "In Cart",
                          style: TextStyle(color: itemData['isCheckout'] ? Colors.blue : Colors.black)),
                      Text(itemData['isDelivered'] ? "Delivered" : "Pending",
                          style: TextStyle(
                              fontSize: 12,
                              color: itemData['isDelivered'] ? Colors.green : Colors.red)),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ),

    );
  }
}
