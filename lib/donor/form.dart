import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_donation_app/donor/d_home.dart';

class DonateForm extends StatefulWidget {
  @override
  _DonateFormState createState() => _DonateFormState();
}

class _DonateFormState extends State<DonateForm> {
  final _formKey = GlobalKey<FormState>();
  String? _foodName;
  String? _description;
  int? _quantity;
  TimeOfDay? _pickupTime;
  String? _location;
  String? _contactInfo;
  String? _duration;

  final List<String> _durations = [
    'Until Midnight',
    '1 Hour',
    '2 Hours',
    '3 Hours',
    '6 Hours',
    '12 Hours',
    '24 Hours',
  ];

  Future<void> _selectPickupTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _pickupTime) {
      setState(() {
        _pickupTime = picked;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      // Get the current user's ID
      String? userId = FirebaseAuth.instance.currentUser?.uid;

      // Store the data in Firestore, including the user ID
      await FirebaseFirestore.instance.collection('donations').add({
        'foodName': _foodName,
        'description': _description,
        'quantity': _quantity,
        'pickupTime': _pickupTime?.format(context),
        'location': _location,
        'contactInfo': _contactInfo,
        'duration': _duration,
        'userId': userId, // Include user ID
        'timestamp': FieldValue.serverTimestamp(), // For ordering
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Donation submitted successfully!")),
      );

      // Navigate back to HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomePage()), // Replace with HomePage
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Donate Food"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: "Food Name"),
                validator: (value) =>
                    value?.isEmpty ?? true ? "Please enter food name" : null,
                onSaved: (value) => _foodName = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Description"),
                validator: (value) => value?.isEmpty ?? true
                    ? "Please enter a description"
                    : null,
                onSaved: (value) => _description = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Quantity"),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value?.isEmpty ?? true ? "Please enter quantity" : null,
                onSaved: (value) => _quantity = int.tryParse(value ?? ""),
              ),
              ListTile(
                title: Text(
                    "Pickup Time: ${_pickupTime?.format(context) ?? "Not selected"}"),
                trailing: Icon(Icons.access_time),
                onTap: () => _selectPickupTime(context),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Location"),
                validator: (value) =>
                    value?.isEmpty ?? true ? "Please enter a location" : null,
                onSaved: (value) => _location = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Contact Information"),
                validator: (value) => value?.isEmpty ?? true
                    ? "Please enter contact information"
                    : null,
                onSaved: (value) => _contactInfo = value,
              ),
              DropdownButtonFormField(
                decoration: InputDecoration(labelText: "Duration"),
                items: _durations
                    .map((duration) => DropdownMenuItem(
                          child: Text(duration),
                          value: duration,
                        ))
                    .toList(),
                validator: (value) =>
                    value == null ? "Please select duration" : null,
                onChanged: (value) {
                  setState(() {
                    _duration = value as String?;
                  });
                },
                onSaved: (value) => _duration = value as String?,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
