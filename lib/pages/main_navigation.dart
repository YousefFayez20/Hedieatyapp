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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: List.generate(
          _pages.length,
              (index) => Offstage(
            offstage: _currentIndex != index,
            child: TickerMode(
              enabled: _currentIndex == index,
              child: FadeTransition(
                opacity: _currentIndex == index ? AlwaysStoppedAnimation(1.0) : AlwaysStoppedAnimation(0.0),
                child: _pages[index],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.green, // Set the same color for selected items
        unselectedItemColor: Colors.grey, // Set the color for unselected items
        selectedIconTheme: IconThemeData(color: Colors.green), // Selected icon color
        unselectedIconTheme: IconThemeData(color: Colors.grey), // Unselected icon color
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Events'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

}
