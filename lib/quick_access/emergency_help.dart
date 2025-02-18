import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import 'package:project_wildeye/models/contact.dart';

class EmergencyHelp extends StatefulWidget {
  const EmergencyHelp({super.key});

  @override
  State<EmergencyHelp> createState() => _EmergencyHelpState();
}

class _EmergencyHelpState extends State<EmergencyHelp> {
  final List<Contact> _contacts = [];

  void _addContact(String name, String number) {
    setState(() {
      _contacts.add(Contact(name: name, phoneNumber: number));
    });
    Navigator.of(context).pop();
  }

  void _showAddContactDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController numberController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white, // Set background color to white
          title: Text(
            'Add New Contact',
            style: GoogleFonts.raleway(), // Apply Raleway font
          ),
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
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // Allow only digits
                ],
                maxLength: 10, // Limit to 10 digits
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.raleway(), // Apply Raleway font
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final number = numberController.text.trim();
                if (name.isNotEmpty && number.isNotEmpty) {
                  if (number.length == 10) {
                    // Validate phone number length
                    _addContact(name, number);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Please enter a valid 10-digit phone number.',
                          style: GoogleFonts.raleway(), // Apply Raleway font
                        ),
                      ),
                    );
                  }
                }
              },
              child: Text(
                'Add',
                style: GoogleFonts.raleway(), // Apply Raleway font
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchDialer(String number) async {
    final Uri url = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Could not launch dialer for $number',
                style: GoogleFonts.raleway())), // Apply Raleway font
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          ), // Apply Raleway font
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _contacts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/empty_contact.png', height: 150),
                          const SizedBox(height: 20),
                          Text(
                            'No contacts added yet.',
                            style: GoogleFonts.raleway(
                                fontSize: 20), // Apply Raleway font
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _showAddContactDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Add Contact',
                              style: GoogleFonts.raleway(
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight.bold), // Apply Raleway font
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _contacts.length,
                      itemBuilder: (context, index) {
                        final contact = _contacts[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white, // Keep the box color white
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
                                      style: GoogleFonts.raleway(
                                          fontSize: 20,
                                          fontWeight: FontWeight
                                              .bold), // Apply Raleway font
                                    ),
                                    const SizedBox(height: 5),
                                    GestureDetector(
                                      onTap: () =>
                                          _launchDialer(contact.phoneNumber),
                                      child: Text(
                                        contact.phoneNumber,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 16,
                                          color: Colors.black,
                                          decoration: TextDecoration
                                              .none, // No underline
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.call,
                                        color: Colors.green),
                                    onPressed: () =>
                                        _launchDialer(contact.phoneNumber),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        _contacts.removeAt(index);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            if (_contacts.isNotEmpty) // Show button only if contacts exist
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: _showAddContactDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent, // Button color
                      foregroundColor: Colors.white, // Text color
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Add Contact',
                      style: GoogleFonts.raleway(
                          fontSize: 18,
                          fontWeight: FontWeight.bold), // Apply Raleway font
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
