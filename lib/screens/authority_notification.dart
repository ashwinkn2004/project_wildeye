import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthorityNotificationScreen extends StatelessWidget {
  const AuthorityNotificationScreen({super.key});

  // Function to fetch notifications from Firestore
  Future<List<Map<String, dynamic>>> _fetchNotifications() async {
    try {
      // Fetch documents from the 'authorityNotification' collection
      final querySnapshot = await FirebaseFirestore.instance
          .collection('authorityReport')
          .get();

      // Convert documents to a list of maps
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching notifications: $e');
      return []; // Return an empty list in case of error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Page background color
      appBar: AppBar(
        title: const Text('Authority Notifications'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black), // Back button color
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No alerts',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          } else {
            final notifications = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5), // Professional container color
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.5), // Border color
                      width: 1, // Border width
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 5,
                        spreadRadius: 1,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification['title'] ?? 'No Title',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notification['message'] ?? 'No Message',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}