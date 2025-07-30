import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderTrackingMap extends StatefulWidget {
  final String orderId;

  const OrderTrackingMap({Key? key, required this.orderId}) : super(key: key);

  @override
  State<OrderTrackingMap> createState() => _OrderTrackingMapState();
}

class _OrderTrackingMapState extends State<OrderTrackingMap> {
  final MapController _mapController = MapController();
  Map<String, dynamic>? _orderData;
  bool _isLoading = true;
  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _fetchOrderData();
  }

  Future<void> _fetchOrderData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .get();

      if (!snapshot.exists) throw Exception('Order not found');
      final data = snapshot.data();
      if (data == null || data['userId'] != user.uid) {
        throw Exception('Unauthorized or invalid order access');
      }

      setState(() {
        _orderData = data;
        _isLoading = false;
      });

      _setupMarkers();
    } catch (e) {
      log('Order fetch error: $e');
      setState(() => _isLoading = false);
    }
  }

  void _setupMarkers() {
    if (_orderData == null) return;

    List<Marker> markers = [];
    List<LatLng> points = [];

    void addMarkerIfPresent(String key, Color color, String label) {
      if (_orderData!.containsKey(key)) {
        final location = _orderData![key];
        final latLng = LatLng(location['lat'], location['lng']);
        points.add(latLng);
        markers.add(Marker(
          point: latLng,
          width: 80,
          height: 80,
          child: _buildCustomMarker(color, label),
        ));
      }
    }

    addMarkerIfPresent('officeAddress', Colors.blue, 'Office');
    addMarkerIfPresent('deliveryAddress', Colors.green, 'Delivery');
    addMarkerIfPresent('currentAddress', Colors.red, 'Current');

    setState(() => _markers = markers);
    if (points.isNotEmpty) _fitMarkersToBounds(points);
  }

  Widget _buildCustomMarker(Color color, String label) {
    return Column(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  void _fitMarkersToBounds(List<LatLng> points) {
    if (points.isEmpty) return;

    double minLat = points.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
    double maxLat = points.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
    double minLng = points.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
    double maxLng = points.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);

    final centerLat = (minLat + maxLat) / 2;
    final centerLng = (minLng + maxLng) / 2;

    final latDelta = maxLat - minLat;
    final lngDelta = maxLng - minLng;
    final maxDelta = [latDelta, lngDelta].reduce((a, b) => a > b ? a : b);

    double zoom = 12;
    if (maxDelta <= 0.01) zoom = 15;
    else if (maxDelta <= 0.05) zoom = 13;
    else if (maxDelta <= 0.1) zoom = 12;
    else if (maxDelta <= 0.5) zoom = 10;
    else zoom = 8;

    _mapController.move(LatLng(centerLat, centerLng), zoom);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.teal;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultLocation = LatLng(27.7000, 85.3117);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_orderData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Tracking')),
        body: const Center(child: Text('Order not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Order #${widget.orderId}')),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: defaultLocation,
                initialZoom: 12,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(markers: _markers),
              ],
            ),
          ),

          if (_orderData!.containsKey('status'))
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                children: [
                  const Text(
                    'Order Status: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _orderData!['status'],
                    style: TextStyle(
                      color: _getStatusColor(_orderData!['status']),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Map Legend', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          _buildLegendItem(Colors.blue, 'Office Location'),
          _buildLegendItem(Colors.green, 'Delivery Location'),
          _buildLegendItem(Colors.red, 'Current Location'),
          _buildLegendItem(Colors.orange, 'Delivery Route', isLine: true),
          const SizedBox(height: 8),
          const Text('© NestCart', style: TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, {bool isLine = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: isLine ? 16 : 16,
            height: isLine ? 4 : 16,
            decoration: BoxDecoration(
              color: color,
              shape: isLine ? BoxShape.rectangle : BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
