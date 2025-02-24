import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApproveNominations extends StatelessWidget {
  final String electionId;

  const ApproveNominations({required this.electionId, super.key});

  void _updateNominationStatus(String nominationId, String status) async {
    var nominationRef = FirebaseFirestore.instance
        .collection("elections")
        .doc(electionId)
        .collection("nominations")
        .doc(nominationId);

    if (status == "approved") {
      await nominationRef.update({"status": status, "voteCount": 0});
    } else {
      await nominationRef.update({"status": status});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Approve Nominations")),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text("Pending Nominations", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("elections")
                  .doc(electionId)
                  .collection("nominations")
                  .where("status", isEqualTo: "pending")
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                var nominations = snapshot.data!.docs;
                return nominations.isEmpty
                    ? const Center(child: Text("No pending nominations."))
                    : ListView.builder(
                        itemCount: nominations.length,
                        itemBuilder: (context, index) {
                          var nomination = nominations[index];
                          return ListTile(
                            title: Text(nomination["candidateName"]),
                            subtitle: Text("Post ID: ${nomination["postId"]}"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check, color: Colors.green),
                                  onPressed: () => _updateNominationStatus(nomination.id, "approved"),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  onPressed: () => _updateNominationStatus(nomination.id, "rejected"),
                                ),
                              ],
                            ),
                          );
                        },
                      );
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text("Approved & Rejected Nominations", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("elections")
                  .doc(electionId)
                  .collection("nominations")
                  .where("status", whereIn: ["approved", "rejected"])
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                var nominations = snapshot.data!.docs;
                return nominations.isEmpty
                    ? const Center(child: Text("No approved/rejected nominations."))
                    : ListView.builder(
                        itemCount: nominations.length,
                        itemBuilder: (context, index) {
                          var nomination = nominations[index];
                          return ListTile(
                            title: Text(nomination["candidateName"]),
                            subtitle: Text("Post ID: ${nomination["postId"]}"),
                            trailing: Text(
                              nomination["status"].toUpperCase(),
                              style: TextStyle(
                                color: nomination["status"] == "approved" ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      );
              },
            ),
          ),
        ],
      ),
    );
  }
}
