import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // ✅ Import intl for date formatting
import 'create_election.dart';
import '../auth/login_screen.dart';
import 'election_dashboard.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  Future<void> _deleteElection(BuildContext context, String electionId) async {
    bool confirmDelete = await _showDeleteDialog(context);
    if (confirmDelete) {
      await FirebaseFirestore.instance.collection("elections").doc(electionId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Election deleted successfully!")),
      );
    }
  }

  Future<bool> _showDeleteDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Confirm Delete"),
            content: const Text("Are you sure you want to delete this election?"),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Panel")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildButton(context, "Create Election", const CreateElection()),
          _buildLogoutButton(context),
          const SizedBox(height: 20),
          const Text(
            "Created Elections",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('elections').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var elections = snapshot.data!.docs;

                if (elections.isEmpty) {
                  return const Center(child: Text("No elections created yet."));
                }

                return ListView.builder(
                  itemCount: elections.length,
                  itemBuilder: (context, index) {
                    var election = elections[index];
                    return _buildElectionCard(context, election);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElectionCard(BuildContext context, DocumentSnapshot election) {
    String endDateStr = election['endDate'] ?? "Unknown";
    DateTime? endDate;

    if (election['endDate'] is Timestamp) {
      endDate = (election['endDate'] as Timestamp).toDate();
    } else {
      try {
        endDate = DateFormat("yyyy-MM-dd HH:mm:ss").parse(endDateStr);
      } catch (e) {
        endDate = null;
      }
    }

    bool hasEnded = endDate != null && DateTime.now().isAfter(endDate);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      elevation: 4,
      child: ListTile(
        title: Text(election['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Start: ${election['startDate']} - End: ${election['endDate']}", style: const TextStyle(color: Colors.grey)),
            if (hasEnded) // ✅ Show election ended status
              const Padding(
                padding: EdgeInsets.only(top: 5),
                child: Text(
                  "Election Ended",
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility, color: Colors.blue),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ElectionDashboard(electionId: election.id, electionTitle: election['title']),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteElection(context, election.id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, Widget page) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: () => _logout(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text("Logout", style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
