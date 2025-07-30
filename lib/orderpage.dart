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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<String> tabs = ['Ongoing', 'Order Placed', 'Canceled'];
  int selectedIndex = 0;

  Stream<QuerySnapshot> getUserCart(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('cart')
        .snapshots();
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("My Orders", style: TextStyle(color: Colors.white),),
      centerTitle: true,
      iconTheme: IconThemeData(
        color: Colors.white
      ),),
      body: StreamBuilder<QuerySnapshot>(
        stream: getUserCart(_auth.currentUser!.uid),
        builder: (context, cartSnapshot) {
          if (cartSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!cartSnapshot.hasData || cartSnapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No items in cart."));
          }

          // Filter only checked out items
          final cartItems = cartSnapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['isCheckout'] == true;
          }).toList();

          if (cartItems.isEmpty) {
            return const Center(child: Text("No orders placed yet."));
          }

          return ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final cartItem = cartItems[index];
              final itemData = cartItem.data() as Map<String, dynamic>;

              final orderId = itemData['orderDetails']['orderId'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('orders').doc(orderId).get(),
                builder: (context, orderSnapshot) {
                  if (!orderSnapshot.hasData ||
                      !orderSnapshot.data!.exists ||
                      orderSnapshot.data!.data() == null) {
                    return const SizedBox.shrink();
                  }

                  final orderData = orderSnapshot.data!.data() as Map<String, dynamic>;
                  final orderStatus = orderData['status'] ?? 'Unknown';

                  // Get the list of items from global order document
                  final List<dynamic> orderItems = orderData['items'] ?? [];

                  // Find matching item in global order by productId
                  final matchingOrderItem = orderItems.firstWhere(
                        (element) => element['productId'] == itemData['productId'],
                    orElse: () => null,
                  );

                  // Use qty from global order item; fallback to cart qty if not found
                  final qtyFromOrder = matchingOrderItem != null
                      ? matchingOrderItem['qty']
                      : itemData['qty'];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderTrackingMap(orderId: orderId),
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                      child: ListTile(
                        leading: Image.memory(
                          base64Decode(itemData['image']),
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(itemData['name']),
                        subtitle: Text("Qty: $qtyFromOrder • Rs.${itemData['price']}"),
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Checked Out", style: TextStyle(color: Colors.purple)),
                             SizedBox(height: 4),
                            Text(
                              orderStatus,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: getStatusColor(orderStatus),

                            ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
