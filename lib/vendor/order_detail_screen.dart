import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'package:geocoding/geocoding.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  bool _isLoading = true;
  String? _status;
  String? _deliveryAddressName;

  final List<String> _statuses = [
    'Pending',
    'Processing',
    'Out for Delivery',
    'Delivered',
    'Cancelled',
  ];

  Map<String, dynamic>? _orderData;

  @override
  void initState() {
    super.initState();
    _fetchOrder();
  }

  Future<void> _fetchOrder() async {
    final orderDoc = await FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.orderId)
        .get();

    if (!orderDoc.exists) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order not found.')),
      );
      Navigator.pop(context);
      return;
    }

    final orderData = orderDoc.data()!;
    final userId = orderData['userId'];

    // Fetch user details
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    String? userName;
    if (userDoc.exists) {
      userName = userDoc.data()?['name'] ?? 'Unknown';
    }

    // Extract delivery location
    final deliveryLat = orderData['deliveryAddress']?['lat'];
    final deliveryLng = orderData['deliveryAddress']?['lng'];

    if (deliveryLat != null && deliveryLng != null) {
      await _getAddressFromLatLng(deliveryLat, deliveryLng);
    } else {
      _deliveryAddressName = 'Location not provided';
    }

    setState(() {
      _orderData = {
        ...orderData,
        'userName': userName ?? userId,
      };
      _status = orderData['status'] ?? 'Pending';
      _isLoading = false;
    });
  }


  Future<void> _getAddressFromLatLng(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _deliveryAddressName = [
            place.name,
            place.subLocality,
            place.locality,
            place.administrativeArea,
            place.country,
          ].where((e) => e != null && e.isNotEmpty).join(', ');
        });
      } else {
        setState(() {
          _deliveryAddressName = 'Unknown location';
        });
      }
    } catch (e) {
      print('Reverse geocoding error: $e');
      setState(() {
        _deliveryAddressName = 'Could not fetch location';
      });
    }
  }


  Future<void> _saveChanges() async {
    if (_status == null) return;
    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .update({'status': _status});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }

    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final order = _orderData;
    if (order == null) {
      return const Scaffold(body: Center(child: Text('Order not found.')));
    }

    final deliveryLatLng = LatLng(
      order['deliveryAddress']?['lat'] ?? 0.0,
      order['deliveryAddress']?['lng'] ?? 0.0,
    );

    return Scaffold(
      appBar: AppBar(title: Text('Order #${widget.orderId}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('Customer: ${order['userName'] ?? 'N/A'}'),
            Text('Payment Method: ${order['paymentMethod']}'),
            Text('Order Date: ${order['orderDate'].toDate()}'),
            const SizedBox(height: 16),

            const Text('Delivery Address:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              _deliveryAddressName != null
                  ? _deliveryAddressName!
                  : order['deliveryAddress']?['lat'] != null
                  ? '(${order['deliveryAddress']['lat']}, ${order['deliveryAddress']['lng']})'
                  : 'Address unavailable',
            ),

            const SizedBox(height: 8),

            SizedBox(
              height: 200,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: deliveryLatLng,
                  initialZoom: 15,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: deliveryLatLng,
                        width: 40,
                        height: 40,
                        child: const Icon(Icons.location_pin, size: 40, color: Colors.red),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...List.generate((order['items'] as List).length, (index) {
              final item = order['items'][index];
              final base64Image = item['image'];

              Uint8List? imageBytes;
              if (base64Image != null && base64Image is String && base64Image.isNotEmpty) {
                try {
                  imageBytes = base64Decode(base64Image);
                } catch (e) {
                  imageBytes = null;
                }
              }

              return ListTile(
                leading: imageBytes != null
                    ? Image.memory(
                  imageBytes,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                )
                    : const Icon(
                  Icons.broken_image,
                  size: 40,
                  color: Colors.grey,
                ),
                title: Text(item['name'] ?? 'Unnamed'),
                subtitle: Text('Qty: ${item['qty']} • ₹${item['price']}'),
              );
            }),

            const Divider(height: 32),
            Text('Subtotal: ₹${order['subtotal']}'),
            Text('Tax: ₹${order['tax']}'),
            Text('Shipping: ₹${order['shipping']}'),
            Text('Total: ₹${order['total']}', style: const TextStyle(fontWeight: FontWeight.bold)),

            const Divider(height: 32),

            Form(
              key: _formKey,
              child: DropdownButtonFormField<String>(
                value: _statuses.contains(_status) ? _status : null,
                items: _statuses
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (value) => setState(() => _status = value),
                decoration: const InputDecoration(
                  labelText: 'Update Status',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _isSaving ? null : _saveChanges,
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Save Status'),
            ),
          ],
        ),
      ),
    );
  }
}
