import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_donation_app/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VolunteerProfilePage extends StatefulWidget {
  const VolunteerProfilePage({super.key});

  @override
  State<VolunteerProfilePage> createState() => _VolunteerProfilePageState();
}

class _VolunteerProfilePageState extends State<VolunteerProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? currentUser;
  bool isEditing = false;
  final _formKey = GlobalKey<FormState>();

  String name = '';
  String email = '';
  String phoneNumber = '';
  String address = '';

  final Color _backgroundColor = const Color(0xFFF5F5F5);
  final Color _primaryColor = const Color(0xFFB19CD9); // Soft purple
  final Color _buttonColor = const Color(0xFF8A6BBE); // Complementary shade
  final Color _textColor = const Color(0xFF333333); // Dark text color

  @override
  void initState() {
    super.initState();
    currentUser = _auth.currentUser;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (currentUser != null) {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(currentUser!.uid).get();
      if (doc.exists) {
        setState(() {
          final data = doc.data() as Map<String, dynamic>;
          name = data['name'];
          email = data['email'];
          phoneNumber = data['phoneNumber'];
          address = data['address'];
        });
      }
    }
  }

  void _toggleEdit() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      await _firestore.collection('users').doc(currentUser!.uid).update({
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'address': address,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully!')),
      );
      setState(() {
        isEditing = false;
      });
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userRole');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: _primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isEditing
            ? Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _buildTextField(
                      label: 'Name',
                      value: name,
                      icon: Icons.person,
                      onChanged: (value) => name = value,
                    ),
                    _buildTextField(
                      label: 'Email',
                      value: email,
                      icon: Icons.email,
                      onChanged: (value) => email = value,
                    ),
                    _buildTextField(
                      label: 'Phone Number',
                      value: phoneNumber,
                      icon: Icons.phone,
                      onChanged: (value) => phoneNumber = value,
                    ),
                    _buildTextField(
                      label: 'Address',
                      value: address,
                      icon: Icons.location_on,
                      onChanged: (value) => address = value,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _buttonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: _saveChanges,
                      child: const Text('Save Changes'),
                    ),
                    TextButton(
                      onPressed: _toggleEdit,
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileInfo('Name', name, Icons.person),
                  _buildProfileInfo('Email', email, Icons.email),
                  _buildProfileInfo('Phone', phoneNumber, Icons.phone),
                  _buildProfileInfo('Address', address, Icons.location_on),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: _toggleEdit,
                    child: const Text('Edit Profile'),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String value,
    required IconData icon,
    required Function(String) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: _textColor),
          prefixIcon: Icon(icon, color: _primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: _primaryColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: _primaryColor),
          ),
        ),
        onChanged: onChanged,
        validator: (value) =>
            value!.isEmpty ? 'Please enter your $label' : null,
      ),
    );
  }

  Widget _buildProfileInfo(String label, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(icon, color: _primaryColor),
        title: Text(
          label,
          style: TextStyle(fontSize: 14, color: _textColor),
        ),
        subtitle: Text(
          value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
