import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_donation_app/delivery/v_home.dart';
import 'package:food_donation_app/donor/d_home.dart';
import 'package:food_donation_app/login.dart';
import 'package:food_donation_app/recipient/r_home.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Donation App',
      debugShowCheckedModeBanner: false,
      home: AuthCheck(),
    );
  }
}

class AuthCheck extends StatelessWidget {
  Future<String?> getUserRole(String uid) async {
    // Retrieve role from shared preferences
    final prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString('userRole');

    // If role isn't stored locally, fetch it from Firestore
    if (role == null) {
      DocumentSnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (snapshot.exists) {
        role = snapshot['role'];
        await prefs.setString('userRole', role!); // Store role locally
      }
    }
    return role;
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return LoginPage();
    } else {
      return FutureBuilder<String?>(
        future: getUserRole(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return LoginPage();
          }

          final role = snapshot.data;
          if (role == 'Donor') {
            return HomePage();
          } else if (role == 'Recipient') {
            return DonationsListPage();
          } else {
            return VolunteerHomePage();
          }
        },
      );
    }
  }
}
