import 'package:flutter/material.dart';
import 'event_list_page.dart';
import 'home_page.dart';
import 'profile_page.dart';

class MainNavigation extends StatefulWidget {
  final int userId; // Add a required userId parameter

  const MainNavigation({Key? key, required this.userId}) : super(key: key);

  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  late final List<Widget> _pages; // Declare pages dynamically based on userId

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(userId: widget.userId),         // Pass userId to Home Page
      EventListPage(userId: widget.userId),    // Pass userId to Event List Page
      UserProfilePage(userId: widget.userId),  // Pass userId to Profile Page
      Placeholder(),                           // Replace GiftListPage or add functionality
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.green,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: 'Gifts',
          ),
        ],
      ),
    );
  }
}
