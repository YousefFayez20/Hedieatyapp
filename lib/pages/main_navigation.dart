import 'package:flutter/material.dart';
import 'event_list_page.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'notification_center_page.dart'; // Import the Notification Center Page

class MainNavigation extends StatefulWidget {
  final int userId;

  const MainNavigation({Key? key, required this.userId}) : super(key: key);

  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(userId: widget.userId),          // Home Page
      EventListPage(userId: widget.userId),     // Events Page
      NotificationCenterPage(userId: widget.userId), // Notifications Page
      UserProfilePage(userId: widget.userId),   // Profile Page
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications', // Updated to "Notifications"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
