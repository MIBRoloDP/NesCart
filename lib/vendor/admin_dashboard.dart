import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:neskart/createProducts.dart';
import 'package:neskart/home_page.dart';
import 'package:neskart/vendor/manage_customer_screen.dart';
import 'package:neskart/vendor/manage_items.dart';
import 'package:neskart/vendor/order_detail_screen.dart';
import 'package:neskart/vendor/view_order_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int orderCount = 0;
  int todayTotal = 0;
  int revenueTotal = 0;

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    final now = DateTime.now();
    final ordersSnapshot = await FirebaseFirestore.instance.collection('orders').get();

    int orders = 0;
    int todayOrderCount = 0;
    int totalRevenue = 0;

    for (var doc in ordersSnapshot.docs) {
      final data = doc.data();
      orders++;

      final amount = data['subtotal'] as num? ?? 0;
      totalRevenue += amount.toInt();

      // Use the correct field
      final Timestamp? timestamp = data['orderDate'];
      if (timestamp == null) continue;

      final DateTime orderDate = timestamp.toDate();
      if (orderDate.year == now.year &&
          orderDate.month == now.month &&
          orderDate.day == now.day) {
        todayOrderCount++;
      }
    }

    setState(() {
      orderCount = orders;
      todayTotal = todayOrderCount;
      revenueTotal = totalRevenue;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nescart Admin Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Overview',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 6,
              childAspectRatio: 3 / 2,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _DashboardCard(title: 'Total Orders', value: '$orderCount'),
                _DashboardCard(title: "Today's Orders", value: '$todayTotal'),
                _DashboardCard(title: 'Total Revenue', value: 'Rs $revenueTotal'),
              ],
            ),
            const SizedBox(height: 32),
            const Text('Recent Orders',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .orderBy('orderDate', descending: true)

                  .limit(5)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No recent orders found.'));
                }

                final orders = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: orders.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final order = orders[index].data() as Map<String, dynamic>;
                    final createdAt = (order['orderDate'] as Timestamp?)?.toDate();
                    final dateStr = createdAt != null
                        ? DateFormat('dd MMM, hh:mm a').format(createdAt)
                        : 'N/A';
                    final orderId = order['orderId'] ?? 'N/A';
                    final total = order['total'] ?? 0;
                    final status = order['status'] ?? 'Pending';
                    final userId = order['userId'] ?? '';

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
                      builder: (context, userSnapshot) {
                        String userName = 'Customer';

                        if (userSnapshot.hasData && userSnapshot.data!.exists) {
                          userName = userSnapshot.data!.get('name') ?? 'Customer';
                        }

                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => OrderDetailScreen(orderId: orderId),
                                ),
                              );
                            },

                            title: Text('Order ID: $orderId'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Customer: $userName'),
                                Text('Date: $dateStr'),
                                Text('Total: Rs $total'),
                              ],
                            ),
                            trailing: Text(
                              status,
                              style: TextStyle(
                                color: status == 'Delivered'
                                    ? Colors.green
                                    : Colors.orange,
                                fontWeight: FontWeight.bold,
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

          ],
        ),
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.black),
            child: const Center(
              child: Text(
                "Admin Panel",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          _buildDrawerItem(Icons.dashboard, 'Dashboard', () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const AdminDashboard()));
          }),
          _buildDrawerItem(Icons.receipt_long, 'View Orders', () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ViewOrdersScreen()));
          }),
          _buildDrawerItem(Icons.group, 'Manage Customers', () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ManageCustomersScreen()));
          }),
          _buildDrawerItem(Icons.add_shopping_cart, 'Add Items', () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AdminAddItemsPage()));
          }),
          _buildDrawerItem(Icons.inventory, 'Manage Items', () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ManageItemsScreen()));
          }),
          const Divider(),
          _buildDrawerItem(Icons.logout_outlined, 'Exit', () {
            Navigator.pop(context);
            Navigator.pop(context);
          }),
        ],
      ),
    );
  }

  ListTile _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String value;

  const _DashboardCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
