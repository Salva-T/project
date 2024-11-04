import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_donation_app/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VolunteerHomePage extends StatefulWidget {
  const VolunteerHomePage({super.key});

  @override
  State<VolunteerHomePage> createState() => _VolunteerHomePageState();
}

class _VolunteerHomePageState extends State<VolunteerHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Logout function with confirmation
  Future<void> _logout() async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // No
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Yes
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    // If the user confirmed logout
    if (confirm == true) {
      await _auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userRole'); // Clear stored role
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Volunteer Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout, // Call the logout function with confirmation
          ),
        ],
      ),
      body: const Center(
        child: Text('Welcome to the Volunteer Home Page!'),
      ),
    );
  }
}
