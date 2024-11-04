import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DonationDetailPage extends StatefulWidget {
  final QueryDocumentSnapshot doc;

  DonationDetailPage({required this.doc});

  @override
  _DonationDetailPageState createState() => _DonationDetailPageState();
}

class _DonationDetailPageState extends State<DonationDetailPage> {
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
    final data = widget.doc.data() as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text(data['foodName'] ?? 'Donation Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description: ${data['description'] ?? 'N/A'}',
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Quantity: ${data['quantity'] ?? 'N/A'}',
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Pickup Time: ${data['pickupTime'] ?? 'N/A'}',
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Location: ${data['location'] ?? 'N/A'}',
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Contact: ${data['contactInfo'] ?? 'N/A'}',
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Duration: ${data['duration'] ?? 'N/A'}',
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showGetFoodDialog(context),
                child: Text('Get Food'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
