import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_donation_app/login.dart';
import 'v_profile.dart'; // Import the new profile page

class VolunteerHomePage extends StatefulWidget {
  const VolunteerHomePage({super.key});

  @override
  State<VolunteerHomePage> createState() => _VolunteerHomePageState();
}

class _VolunteerHomePageState extends State<VolunteerHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Volunteer Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person), // Change to profile icon
            onPressed: () {
              // Navigate to profile page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => VolunteerProfilePage()),
              );
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Welcome to the Volunteer Home Page!'),
      ),
    );
  }
}
