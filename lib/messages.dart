import 'package:flutter/material.dart';
import 'package:neskart/support_chat.dart';
import 'activities_page.dart';
import 'coupon_page.dart';
import 'orderpage.dart';

class MessageScreen extends StatefulWidget {
  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final List<Map<String, dynamic>> categories = [
    { 'icon': Icons.photo_camera},
    {'icon': Icons.headphones},
    { 'icon': Icons.table_restaurant},
    { 'icon': Icons.photo_camera},
    {'icon': Icons.headphones},
    { 'icon': Icons.table_restaurant},
  ];
  final ScrollController _scrollController = ScrollController();
  bool _isScrolledDown = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients && _scrollController.offset > (180 - 60) * 0.3) { // Adjusted threshold dynamically
      if (!_isScrolledDown) {
        setState(() {
          _isScrolledDown = true;
        });
      }
    } else {
      if (_isScrolledDown) {
        setState(() {
          _isScrolledDown = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFe8dfd4),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            pinned: true,
            backgroundColor: const Color(0xFFe8dfd4),
            expandedHeight: 150,
            collapsedHeight: 60,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              title: AnimatedOpacity(
                opacity: _isScrolledDown ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 100),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) =>  supportPage(),),
                        );
                      },
                      child: Icon(Icons.support_agent,
                      color: Colors.green,
                      ),
                    ), GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => OrderPage(),),
                        );
                      },
                      child: Icon(Icons.inventory,

                      color: Colors.blue,),
                    ),
                    GestureDetector(onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => SalesDashboardPage(),),
                      );
                    },
                      child: Icon(Icons.flash_on,
                      color: Colors.orange,
                      ),
                    ), GestureDetector(
              onTap: (){  Navigator.push(context, MaterialPageRoute(builder: (context) =>  CouponsPage()));},
                      child: Icon(Icons.campaign,
                      color: Colors.pink
                      ),
                    ),
                  ],
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
              background: Container(
                color: const Color(0xFFe8dfd4),
                padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AnimatedOpacity(
                          opacity: _isScrolledDown ? 0.0 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: const Text(
                            "Messages",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // Row(
                        //   children: [
                        //     Icon(Icons.cleaning_services_outlined,
                        //         size: 16, color: Colors.black),
                        //     const SizedBox(width: 4),
                        //     Text(
                        //       "Mark all as read",
                        //       style: TextStyle(color: Colors.black),
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    AnimatedOpacity(
                      opacity: _isScrolledDown ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: LayoutBuilder(
                          builder: (context, constraints) {
                            return AnimatedBuilder(
                              animation: _scrollController,
                              builder: (context, child) {
                                final settings = context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
                                if (settings == null) {
                                  return const SizedBox.shrink();
                                }
                                final double deltaExtent = settings.maxExtent - settings.minExtent;
                                final double t = deltaExtent > 0 ? ((settings.currentExtent - settings.minExtent) / deltaExtent).clamp(0.0, 1.0) : 0.0;
                                const double maxRadius = 22;
                                const double minRadius = 5;
                                const double maxIconSize = 24;
                                const double minIconSize = 10;
                                const double maxTextSize = 12;
                                const double minTextSize = 0;

                                final double currentRadius = Tween<double>(begin: minRadius, end: maxRadius).evaluate(AlwaysStoppedAnimation(t));
                                final double currentIconSize = Tween<double>(begin: minIconSize, end: maxIconSize).evaluate(AlwaysStoppedAnimation(t));
                                final double currentTextSize = Tween<double>(begin: minTextSize, end: maxTextSize).evaluate(AlwaysStoppedAnimation(t));

                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                        onTap: (){
                                          Navigator.push(context, MaterialPageRoute(builder: (context) =>  supportPage()),
                                          );
                                        },
                                        child: _buildCategoryColumn(Icons.support_agent, Colors.green, "Support", null, currentRadius, currentIconSize, currentTextSize)),
                                    GestureDetector(
                                        onTap: (){
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => OrderPage(),),
                                          );
                                        },
                                        child: _buildCategoryColumn(Icons.inventory, Colors.blue, "Orders", null, currentRadius, currentIconSize, currentTextSize)),
                                    GestureDetector(
                                        onTap: (){
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => SalesDashboardPage(),),
                                          );
                                        },
                                        child: _buildCategoryColumn(Icons.flash_on, Colors.orange, "Activities", null, currentRadius, currentIconSize, currentTextSize)),
                                    GestureDetector(  onTap: (){
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => CouponsPage(),),
                                      );
                                    },
                                        child: _buildCategoryColumn(Icons.campaign, Colors.pink, "Promos", "dot", currentRadius, currentIconSize, currentTextSize)),
                                  ],
                                );
                              },
                            );
                          }
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Text(
                "Last 7 days",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                if (index == 0) {
                  return _buildMessageCard(
                    "Study & Work Essential😍",
                    "FLAT 10% OFF + FREE Delivery on all products🥰💖",
                    "5 minutes ago",
                    "https://images.unsplash.com/photo-1555529669-2269763671c0?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTF8fHNob3BwaW5nfGVufDB8fDB8fHww",
                  );
                } else if (index == 1) {
                  return _buildMessageCard(
                    "Transform Your Skin with Rohto🌟",
                    "With up to 30% OFF on all your favorite products🧖‍♀️💖",
                    "13:30 PM",
                    "https://plus.unsplash.com/premium_photo-1672883552013-506440b2f11c?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8ZWNvbW1lcmNlJTIwb2ZmZXJzfGVufDB8fDB8fHww",
                  );
                } else {
                  return _buildMessageCard(
                    "Shop Without Worries🤗",
                    "Claim voucher to enjoy Free Delivery at Rs 499 minimum spend",
                    "11:30 AM",
                    "https://images.unsplash.com/photo-1516888531328-d33c9aa594a7?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8ZHJhZ29uJTVDfGVufDB8fDB8fHww",
                  );
                }
              },
              childCount: 3,
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }
  Widget _buildCategoryColumn(IconData icon, Color color, String text, String? notificationCount, double radius, double iconSize, double textSize) {
    if (radius <= 0 || iconSize <= 0) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              radius: radius, // Use dynamic radius
              child: Icon(icon, color: color, size: iconSize),
            ),
            if (notificationCount != null && radius > (22 * 0.5))
              Positioned(
                right: 0,
                top: 0,
                child: notificationCount == "dot"
                    ? Container(
                  width: radius * 0.4,
                  height: radius * 0.4,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                )
                    : Container(
                  padding: EdgeInsets.all(radius * 0.18),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    notificationCount,
                    style: TextStyle(
                        fontSize: radius * 0.4,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: textSize > 0 ? 4 : 0),
        if (textSize > 0)
          Text(
            text,
            style: TextStyle(fontSize: textSize),
          ),
      ],
    );
  }
  Widget _buildMessageCard(String title, String content, String time, String imageUrl) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.campaign, color: Colors.pink),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                time,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              imageUrl,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 150,
                  width: double.infinity,
                  color: Colors.grey[200],
                  alignment: Alignment.center,
                  child: Icon(Icons.broken_image, color: Colors.grey[400], size: 50),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}