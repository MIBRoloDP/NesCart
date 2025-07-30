import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageCustomersScreen extends StatefulWidget {
  const ManageCustomersScreen({super.key});

  @override
  State<ManageCustomersScreen> createState() => _ManageCustomersScreenState();
}

class _ManageCustomersScreenState extends State<ManageCustomersScreen> {
  Future<void> toggleUserStatus(String userId, String currentStatus) async {
    final newStatus = currentStatus == 'Blocked' ? 'Active' : 'Blocked';

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'status': newStatus});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFe8dfd4),
      appBar: AppBar(
        title: const Text('Manage Customers'),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('admin', isEqualTo: false)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          if (users.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final data = user.data() as Map<String, dynamic>;

              final name = data['name'] ?? 'Unnamed';
              final email = data['email'] ?? 'No Email';
              final status = data['status'] ?? 'Active';
              final orders = data['orders'] ?? 0;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  title: Text(name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Email: $email'),
                      Text('Total Orders: $orders'),
                    ],
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      status == 'Blocked' ? Colors.green : Colors.redAccent,
                    ),
                    onPressed: () async {
                      await toggleUserStatus(user.id, status);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(status == 'Blocked'
                              ? 'Unblocked $name'
                              : 'Blocked $name'),
                        ),
                      );
                    },
                    child: Text(status == 'Blocked' ? 'Unblock' : 'Block', style: TextStyle(color: Colors.white),),
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
