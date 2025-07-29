import 'package:flutter/material.dart';

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
                    Icon(Icons.chat,
                    color: Colors.green,
                    ), Icon(Icons.inventory,

                    color: Colors.blue,), Icon(Icons.flash_on,
                    color: Colors.orange,
                    ), Icon(Icons.campaign,
                    color: Colors.pink
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
                        Row(
                          children: [
                            Icon(Icons.cleaning_services_outlined,
                                size: 16, color: Colors.black),
                            const SizedBox(width: 4),
                            Text(
                              "Mark all as read",
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // CORRECTED SECTION:
                    // The AnimatedBuilder needs to be directly within the background
                    // to access the FlexibleSpaceBarSettings provided by the FlexibleSpaceBar.
                    AnimatedOpacity(
                      opacity: _isScrolledDown ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: LayoutBuilder( // Using LayoutBuilder to get constraints if needed, or simply return AnimatedBuilder
                          builder: (context, constraints) {
                            return AnimatedBuilder(
                              animation: _scrollController,
                              builder: (context, child) {
                                final settings = context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
                                if (settings == null) {
                                  // Fallback or a placeholder if settings are not available
                                  return const SizedBox.shrink(); // Or a default row
                                }

                                // Calculate the scroll progress from 0.0 (expanded) to 1.0 (collapsed)
                                // settings.currentExtent decreases from maxExtent to minExtent
                                // So, t should go from 1.0 (expanded) to 0.0 (collapsed)
                                final double deltaExtent = settings.maxExtent - settings.minExtent;
                                // Ensure deltaExtent is not zero to avoid division by zero
                                final double t = deltaExtent > 0 ? ((settings.currentExtent - settings.minExtent) / deltaExtent).clamp(0.0, 1.0) : 0.0;


                                // Calculate scaled size for icons
                                // We want them to scale from normal size (t=1) to smaller (t=0)
                                // Max radius for circle avatar: 22 (from your original code)
                                // Let's make them shrink to a smaller size, not completely disappear, e.g., radius 5, icon 10, text 0
                                const double maxRadius = 22;
                                const double minRadius = 5;
                                const double maxIconSize = 24; // Assuming icon size inside 22 radius
                                const double minIconSize = 10;
                                const double maxTextSize = 12; // Your original text size
                                const double minTextSize = 0; // Text can disappear

                                final double currentRadius = Tween<double>(begin: minRadius, end: maxRadius).evaluate(AlwaysStoppedAnimation(t));
                                final double currentIconSize = Tween<double>(begin: minIconSize, end: maxIconSize).evaluate(AlwaysStoppedAnimation(t));
                                final double currentTextSize = Tween<double>(begin: minTextSize, end: maxTextSize).evaluate(AlwaysStoppedAnimation(t));

                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildCategoryColumn(Icons.chat, Colors.green, "Chats", null, currentRadius, currentIconSize, currentTextSize),
                                    _buildCategoryColumn(Icons.inventory, Colors.blue, "Orders", null, currentRadius, currentIconSize, currentTextSize),
                                    _buildCategoryColumn(Icons.flash_on, Colors.orange, "Activities", "2", currentRadius, currentIconSize, currentTextSize),
                                    _buildCategoryColumn(Icons.campaign, Colors.pink, "Promos", "dot", currentRadius, currentIconSize, currentTextSize),
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
                // ... (your message card building logic) ...
                if (index == 0) {
                  return _buildMessageCard(
                    "Study & Work Essential😍",
                    "FLAT 10% OFF + FREE Delivery on all Deli products🥰💖",
                    "5 minutes ago",
                    "https://images.unsplash.com/photo-1516888531328-d33c9aa594a7?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8ZHJhZ29uJTVDfGVufDB8fDB8fHww",
                  );
                } else if (index == 1) {
                  return _buildMessageCard(
                    "Transform Your Skin with Rohto🌟",
                    "With up to 30% OFF on all your favorite products🧖‍♀️💖",
                    "13:30 PM",
                    "https://images.unsplash.com/photo-1516888531328-d33c9aa594a7?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8ZHJhZ29uJTVDfGVufDB8fDB8fHww",
                  );
                } else {
                  return _buildMessageCard(
                    "Shop Without Worries🤗",
                    "Claim voucher to enjoy Free Delivery at ₹499 minimum spend",
                    "11:30 AM",
                    "https://images.unsplash.com/photo-1516888531328-d33c9aa594a7?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8ZHJhZ29uJTVDfGVufDB8fDB8fHww",
                  );
                }
              },
              childCount: 5,
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  // Helper method to build category columns
  Widget _buildCategoryColumn(IconData icon, Color color, String text, String? notificationCount, double radius, double iconSize, double textSize) {
    // Only show if the size is meaningful
    if (radius <= 0 || iconSize <= 0) { // Text can disappear (size 0)
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              radius: radius, // Use dynamic radius
              child: Icon(icon, color: color, size: iconSize), // Use dynamic iconSize
            ),
            if (notificationCount != null && radius > (22 * 0.5)) // Only show notification if icon is large enough
              Positioned(
                right: 0,
                top: 0,
                child: notificationCount == "dot"
                    ? Container(
                  width: radius * 0.4, // Scale dot size with radius
                  height: radius * 0.4,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                )
                    : Container(
                  padding: EdgeInsets.all(radius * 0.18), // Scale padding
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    notificationCount,
                    style: TextStyle(
                        fontSize: radius * 0.4, // Scale font size with radius
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: textSize > 0 ? 4 : 0), // Adjust spacing based on text visibility
        if (textSize > 0) // Only show text if size is meaningful
          Text(
            text,
            style: TextStyle(fontSize: textSize), // Use dynamic textSize
          ),
      ],
    );
  }

  // Helper method to build message cards (unchanged from previous)
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