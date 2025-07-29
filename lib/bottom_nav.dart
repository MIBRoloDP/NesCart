import 'package:flutter/material.dart';
import 'package:neskart/Profile_page.dart';
import 'package:neskart/messages.dart';
import 'package:neskart/Profile_page.dart';
import 'home_page.dart'; // Make sure this path is correct

class bottomnav extends StatefulWidget {
  const bottomnav({super.key});

  @override
  State<bottomnav> createState() => _bottomnavState();
}

class _bottomnavState extends State<bottomnav> {
  // 1. Declare _selectedIndex as a state variable outside the build method
  int _selectedIndex = 0; // Initialize it here

  // 2. Define your list of pages and icons here as well
  final List<Widget> _pages = [
    homepage(),
    MessageScreen(),
   ProfilePage()
  ];

  final List<IconData> _icons = [
    Icons.home,
    Icons.message_sharp,
    Icons.person
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: IndexedStack(
        index: _selectedIndex,
        // 3. Use the state variable _selectedIndex and the _pages list
        children: _pages,
      ),
      drawerScrimColor: Colors.transparent,
      extendBody: true,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(top: 700, bottom: 0),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 1.5, vertical: 6.5),
            decoration: BoxDecoration(
              color: Colors.black, // translucent
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_icons.length, (index) {
                bool isSelected = _selectedIndex == index;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: InkWell(
                    onTap: () {
                      // 4. Update the state variable using setState
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _icons[index], // Use the _icons list
                        color: isSelected ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}