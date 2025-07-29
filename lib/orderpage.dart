import 'package:flutter/material.dart';
class orders extends StatefulWidget {
  const orders({super.key});

  @override
  State<orders> createState() => _ordersState();
}

class _ordersState extends State<orders> {
  int selectedIndex = 0;
  final tabs = ['Ongoing', 'Completed', 'Canceled'];


  @override
  Widget build(BuildContext context) {
    return Scaffold(body:  Column(
      children: [
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: Color(0xFFF1F1F1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: List.generate(tabs.length, (index) {
                bool isSelected = selectedIndex == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      alignment: Alignment.center,
                      child: index == 1
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            tabs[index],
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.black
                                  : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 4),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          )
                        ],
                      )
                          : Text(
                        tabs[index],
                        style: TextStyle(
                          color: isSelected
                              ? Colors.black
                              : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        SizedBox(height: 40),
        // Content based on selected tab
        if (selectedIndex == 0)
          Text('', style: TextStyle(fontSize: 18))
        else if (selectedIndex == 1)
          Text('', style: TextStyle(fontSize: 18))
        else
          Text('', style: TextStyle(fontSize: 18)),
      ],
    ),

    );
  }
}
