import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'election_dashboard.dart';
import '../auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/common_layout.dart';

class UserHome extends StatelessWidget {
  const UserHome({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      title: "User Panel",
      child: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection("elections").snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var elections = snapshot.data!.docs;

                return elections.isEmpty
                    ? const Center(child: Text("No elections available."))
                    : ListView.builder(
                        itemCount: elections.length,
                        itemBuilder: (context, index) {
                          var election = elections[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            child: ListTile(
                              title: Text(election["title"] ?? "Unnamed Election",
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text("Date: ${election["startDate"] ?? "Unknown"}"),
                              leading: const Icon(Icons.how_to_vote, color: Colors.purple),
                              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ElectionDashboard(
                                      electionId: election.id,
                                      electionTitle: election["title"],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
              },
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _logout(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Logout", style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
