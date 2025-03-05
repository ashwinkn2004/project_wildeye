import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_wildeye/models/contact.dart';

class EmergencyHelp extends StatefulWidget {
  const EmergencyHelp({super.key});

  @override
  State<EmergencyHelp> createState() => _EmergencyHelpState();
}

class _EmergencyHelpState extends State<EmergencyHelp> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Contact> _contacts = [];

  @override
  void initState() {
    super.initState();
    _fetchInitialContacts();
  }

  Future<void> _fetchInitialContacts() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userId = user.uid;
      final querySnapshot = await _firestore
          .collection('contacts')
          .where('userId', isEqualTo: userId)
          .get();
      setState(() {
        _contacts = querySnapshot.docs.map((doc) {
          return Contact(
            name: doc['name'],
            phoneNumber: doc['phoneNumber'],
            userId: doc['userId'],
          );
        }).toList();
      });
    }
  }

  void _showAddContactDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController numberController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Add New Contact', style: GoogleFonts.raleway()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: numberController,
                decoration: const InputDecoration(labelText: 'Contact Number'),
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 10,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: GoogleFonts.raleway()),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final number = numberController.text.trim();
                if (name.isNotEmpty && number.isNotEmpty && number.length == 10) {
                  // Add to local state and close dialog immediately
                  setState(() {
                    _contacts.add(Contact(name: name, phoneNumber: number, userId: _auth.currentUser!.uid));
                  });
                  Navigator.of(context).pop(); // Close dialog instantly
                  _addContact(name, number); // Firestore update in background
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Please enter a valid 10-digit phone number.',
                        style: GoogleFonts.raleway(),
                      ),
                    ),
                  );
                }
              },
              child: Text('Add', style: GoogleFonts.raleway()),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addContact(String name, String number) async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not logged in', style: GoogleFonts.raleway())),
      );
      return;
    }

    final userId = user.uid;

    await _firestore.collection('contacts').add({
      'name': name,
      'phoneNumber': number,
      'userId': userId,
    });
  }

  Future<void> _deleteContact(String contactId, int index) async {
    await _firestore.collection('contacts').doc(contactId).delete();
    setState(() {
      _contacts.removeAt(index);
    });
  }

  Future<void> _launchDialer(String number) async {
    final Uri url = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not launch dialer for $number', style: GoogleFonts.raleway()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text(
            'User not logged in',
            style: GoogleFonts.raleway(fontSize: 20),
          ),
        ),
      );
    }

    final userId = user.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Emergency Contact',
          style: GoogleFonts.raleway(
            color: Colors.black,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('contacts')
                    .where('userId', isEqualTo: userId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    _contacts = snapshot.data!.docs.map((doc) {
                      return Contact(
                        name: doc['name'],
                        phoneNumber: doc['phoneNumber'],
                        userId: doc['userId'],
                      );
                    }).toList();
                  }

                  if (_contacts.isEmpty && snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (_contacts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/empty_contact.png', height: 150),
                          const SizedBox(height: 20),
                          Text(
                            'No contacts added yet.',
                            style: GoogleFonts.raleway(fontSize: 20),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _showAddContactDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Add Contact',
                              style: GoogleFonts.raleway(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: _contacts.length,
                          itemBuilder: (context, index) {
                            final contact = _contacts[index];
                            final contactId = snapshot.hasData ? snapshot.data!.docs[index].id : '';
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          contact.name,
                                          style: GoogleFonts.raleway(fontSize: 20, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 5),
                                        GestureDetector(
                                          onTap: () => _launchDialer(contact.phoneNumber),
                                          child: Text(
                                            contact.phoneNumber,
                                            style: GoogleFonts.montserrat(
                                              fontSize: 16,
                                              color: Colors.black,
                                              decoration: TextDecoration.none,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.call, color: Colors.green),
                                        onPressed: () => _launchDialer(contact.phoneNumber),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _deleteContact(contactId, index),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      if (_contacts.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Center(
                            child: ElevatedButton(
                              onPressed: _showAddContactDialog,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Add Contact',
                                style: GoogleFonts.raleway(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}