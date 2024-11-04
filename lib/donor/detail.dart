import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Detail extends StatefulWidget {
  final DocumentSnapshot doc; // Field to hold the document snapshot

  const Detail({Key? key, required this.doc})
      : super(key: key); // Constructor to accept the document

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  // Function to delete the donation
  Future<void> _deleteDonation() async {
    try {
      // Show a confirmation dialog
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Donation'),
          content: const Text('Are you sure you want to delete this donation?'),
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

      // If the user confirmed deletion
      if (confirm == true) {
        await FirebaseFirestore.instance
            .collection('donations')
            .doc(widget.doc.id)
            .delete();
        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Donation deleted successfully!")),
        );
        // Navigate back after deletion
        Navigator.of(context)
            .pop(); // Optionally, you can navigate to another page if required
      }
    } catch (e) {
      // Handle any errors during deletion
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error deleting donation")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract data from the document snapshot
    final data = widget.doc.data() as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete), // Delete icon
            onPressed: _deleteDonation, // Call delete function when pressed
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data['foodName'] ?? 'No title',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 10),
            Text("Description: ${data['description'] ?? 'N/A'}"),
            SizedBox(height: 10),
            Text("Quantity: ${data['quantity'] ?? 'N/A'}"),
            SizedBox(height: 10),
            Text("Pickup Time: ${data['pickupTime'] ?? 'N/A'}"),
            SizedBox(height: 10),
            Text("Location: ${data['location'] ?? 'N/A'}"),
            SizedBox(height: 10),
            Text("Contact: ${data['contactInfo'] ?? 'N/A'}"),
            SizedBox(height: 10),
            Text("Duration: ${data['duration'] ?? 'N/A'}"),
          ],
        ),
      ),
    );
  }
}
