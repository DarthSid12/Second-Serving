import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:second_serving/helper/colors.dart';
import 'package:second_serving/helper/user.dart';
import 'package:second_serving/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
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
      backgroundColor: Color(0xFF1C1D1F), // Slate black background
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0 ? 'Profile' : 'Donations',
          style: GoogleFonts.nunitoSans(color: Color(0xFFF8F9FA)), // Nearly white text
        ),
        backgroundColor: Color(0xFF2E3239), // Olive gray app bar
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFFF8F9FA)),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Color(0xFFF8F9FA)), // Nearly white
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
        backgroundColor: Color(0xFFA3C9A8), // Sage green
        child: Icon(Icons.add, size: 28, color: Color(0xFF1C1D1F)), // Slate black
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
        backgroundColor: Color(0xFF2E3239), // Olive gray
        selectedItemColor: Color(0xFFA3C9A8), // Sage green
        unselectedItemColor: Color(0xFFF8F9FA).withOpacity(0.5), // Muted white
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
