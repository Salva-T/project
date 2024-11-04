import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_donation_app/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DonationsListPage extends StatefulWidget {
  @override
  _DonationsListPageState createState() => _DonationsListPageState();
}

class _DonationsListPageState extends State<DonationsListPage> {
  final Set<int> _expandedItems = Set<int>();

  // Method to handle logout with confirmation
  Future<void> _logout() async {
    // Show a confirmation dialog
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
      await FirebaseAuth.instance.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userRole'); // Clear stored role
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
    }
  }

  // Method to build the food details dialog
  void _showGetFoodDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Get Food'),
        content: Text('Are you sure you want to get this food?'),
        actions: [
          TextButton(
            onPressed: () {
              // Implement logic to get the food if necessary
              Navigator.of(context).pop();
            },
            child: Text('Yes'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('No'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Available Donations"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout, // Call the logout function when pressed
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('donations')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
                child: Text("Error loading donations: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No donations available"));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final isExpanded = _expandedItems.contains(index);

              return Column(
                children: [
                  ListTile(
                    title: Text(data['foodName'] ?? 'No title'),
                    subtitle: Text(data['description'] ?? 'N/A'),
                    trailing: ElevatedButton(
                      onPressed: () =>
                          _showGetFoodDialog(context), // Call the dialog method
                      child: Text('Get Food'),
                    ),
                    onTap: () {
                      setState(() {
                        if (isExpanded) {
                          _expandedItems.remove(index);
                        } else {
                          _expandedItems.add(index);
                        }
                      });
                    },
                  ),
                  if (isExpanded) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Quantity: ${data['quantity'] ?? 'N/A'}'),
                          Text('Pickup Time: ${data['pickupTime'] ?? 'N/A'}'),
                          Text('Location: ${data['location'] ?? 'N/A'}'),
                          Text('Contact: ${data['contactInfo'] ?? 'N/A'}'),
                          Text('Duration: ${data['duration'] ?? 'N/A'}'),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }
}
