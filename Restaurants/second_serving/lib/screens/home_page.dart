import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:second_serving/helper/user.dart';
import 'package:second_serving/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_screen.dart';
import 'donations_screen.dart';
import 'create_donation.dart';

class HomePage extends StatefulWidget {
  AppUser user;

  HomePage({required this.user});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // List of screens for bottom navigation
  late final List<Widget> _screens;

  // Function to change the selected tab
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  changeUser(AppUser user) {
    setState(() {
      widget.user = user;
      _screens[1] = DonationsScreen(
        user: widget.user,
      );
    });
  }

  // Function to handle the plus button click for creating a donation
  void _onPlusButtonPressed() async {
    AppUser? argument = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => CreateDonationPage(appUser: widget.user)),
    );
    if (argument != null) {
      setState(() {
        widget.user = argument;
      });
      _screens = [
        ProfileScreen(
          user: widget.user,
          changeUser: changeUser,
        ), // Profile tab
        DonationsScreen(
          user: widget.user,
        ), // Donations tab
      ];
    }
  }

  @override
  void initState() {
    _screens = [
      ProfileScreen(
        user: widget.user,
        changeUser: changeUser,
      ), // Profile tab
      DonationsScreen(
        user: widget.user,
      ), // Donations tab
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Color(0xFF32827A),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              // Clear SharedPreferences
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              // Logout from FirebaseAuth
              await FirebaseAuth.instance.signOut();

              // Navigate to Login Screen
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
            
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex], // Display the selected tab's screen
      floatingActionButton: FloatingActionButton(
        onPressed: _onPlusButtonPressed,
        backgroundColor: Color(0xFF42D42D),
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fastfood),
            label: 'Donations',
          ),
        ],
        backgroundColor: Color(0xFF0C0908),
        selectedItemColor: Color(0xFF42D42D),
        unselectedItemColor: Color(0xFFFAFAFF),
      ),
    );
  }
}
