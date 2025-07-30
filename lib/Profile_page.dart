import 'package:flutter/material.dart';

import 'orderpage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text("Profile Page",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold
        ),),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.white,

            onPressed: () {

            }),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.orange.shade100,
                child: const Icon(Icons.person, size: 30, color: Colors.orange),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Dev Pradhan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: const [
                      Text('13 WishList · ', style: TextStyle(fontSize: 12)),
                      Text('11 Followed Stores · ', style: TextStyle(fontSize: 12)),
                      Text('2 Vouchers', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              const Icon(Icons.settings),
            ],
          ),

          const SizedBox(height: 24),
          const Text('My Orders', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: const [
                  Icon(Icons.payment, color: Colors.orange),
                  SizedBox(height: 4),
                  Text('To Pay', style: TextStyle(fontSize: 12)),
                ],
              ),
              GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>OrderPage()));
                },
                child: Column(
                  children: const [
                    Icon(Icons.local_shipping, color: Colors.orange),
                    SizedBox(height: 4),
                    Text('To Ship', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              Column(
                children: const [
                  Icon(Icons.receipt, color: Colors.orange),
                  SizedBox(height: 4),
                  Text('To Receive', style: TextStyle(fontSize: 12)),
                ],
              ),
              Column(
                children: const [
                  Icon(Icons.reviews, color: Colors.orange),
                  SizedBox(height: 4),
                  Text('To Review', style: TextStyle(fontSize: 12)),
                ],
              ),
              Column(
                children: const [
                  Icon(Icons.refresh, color: Colors.orange),
                  SizedBox(height: 4),
                  Text('Returns', style: TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    border: Border.all(color: Colors.purple),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Daraz Gems', style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Text('Get Up to 70% OFF with Gems', style: TextStyle(fontSize: 12)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                        onPressed: () {},
                        child: const Text('Collect', style: TextStyle(color: Colors.white)),
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
                    color: Colors.blue.shade50,
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Daraz Candy', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Text('No Spend, Just Play & Win Gems!', style: TextStyle(fontSize: 12)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                        onPressed: () {},
                        child: const Text('Play Now', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),


          const SizedBox(height: 24),
          const Text('More Options', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              Column(
                children: const [
                  Icon(Icons.mail, size: 28),
                  SizedBox(height: 6),
                  Text("My Messages", style: TextStyle(fontSize: 12)),
                ],
              ),
              Column(
                children: const [
                  Icon(Icons.shopping_cart, size: 28),
                  SizedBox(height: 6),
                  Text("Buy Any 3", style: TextStyle(fontSize: 12)),
                ],
              ),
              Column(
                children: const [
                  Icon(Icons.support_agent, size: 28),
                  SizedBox(height: 6),
                  Text("Customer Care", style: TextStyle(fontSize: 12)),
                ],
              ),
              Column(
                children: const [
                  Icon(Icons.reviews, size: 28),
                  SizedBox(height: 6),
                  Text("My Reviews", style: TextStyle(fontSize: 12)),
                ],
              ),
              Column(
                children: const [
                  Icon(Icons.help, size: 28),
                  SizedBox(height: 6),
                  Text("Help Center", style: TextStyle(fontSize: 12)),
                ],
              ),
              Column(
                children: const [
                  Icon(Icons.style, size: 28),
                  SizedBox(height: 6),
                  Text("Daraz Look", style: TextStyle(fontSize: 12)),
                ],
              ),
              Column(
                children: const [
                  Icon(Icons.group, size: 28),
                  SizedBox(height: 6),
                  Text("Affiliates Care", style: TextStyle(fontSize: 12)),
                ],
              ),
              Column(
                children: const [
                  Icon(Icons.payment, size: 27),
                  SizedBox(height: 6),
                  Text("My Payments", style: TextStyle(fontSize: 12)),
                ],
              ),

            ],
          ),
        ],
      ),
    );
  }
}
