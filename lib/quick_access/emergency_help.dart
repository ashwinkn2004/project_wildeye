import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyHelp extends StatefulWidget {
  const EmergencyHelp({super.key});

  @override
  State<EmergencyHelp> createState() => _EmergencyHelpState();
}

class _EmergencyHelpState extends State<EmergencyHelp> {
  final List<Map<String, String>> _contacts = [];

  void _addContact(String name, String number) {
    setState(() {
      _contacts.add({'name': name, 'number': number});
    });
    Navigator.of(context).pop(); // Close the dialog after adding the contact
  }

  void _showAddContactDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController numberController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Contact'),
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
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final number = numberController.text.trim();
                if (name.isNotEmpty && number.isNotEmpty) {
                  _addContact(name, number);
                }
              },
              child: const Text('Add'),
            ),
          ],
          backgroundColor: Colors.white,
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
        SnackBar(content: Text('Could not launch dialer for $number')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Emergency Contact',
          style: TextStyle(
              color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold),
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
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.add_call,
                    color: Colors.red,
                    size: 40,
                  ),
                  onPressed: _showAddContactDialog,
                ),
                const SizedBox(width: 30),
                const Text(
                  'Add New',
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 25),
                ),
              ],
            ),
            Expanded(
              child: _contacts.isEmpty
                  ? const Center(
                      child: Text(
                        'No contacts added yet.',
                        style: TextStyle(fontSize: 20),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _contacts.length,
                      itemBuilder: (context, index) {
                        final contact = _contacts[index];
                        return ListTile(
                          title: Text(
                            contact['name']!,
                            style: const TextStyle(fontSize: 20),
                          ),
                          subtitle: InkWell(
                            onTap: () => _launchDialer(contact['number']!),
                            child: Text(
                              contact['number']!,
                              style: const TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _contacts.removeAt(index);
                              });
                            },
                          ),
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
