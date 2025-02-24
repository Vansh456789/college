import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/common_layout.dart';

class ResultsPage extends StatelessWidget {
  final String electionId;

  const ResultsPage({required this.electionId, super.key});

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      title: "Election Results",
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("results") // ✅ Correct Collection
            .doc(electionId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Results not yet published."));
          }

          var data = snapshot.data!.data() as Map<String, dynamic>?;

          if (data == null || !data.containsKey("voteResults") || data["voteResults"].isEmpty) {
            return const Center(child: Text("No votes recorded."));
          }

          Map<String, dynamic> voteResults = data["voteResults"];

          return ListView(
            children: voteResults.entries.map((entry) {
              Map<String, dynamic> candidateData = entry.value;
              String candidateName = candidateData["candidateName"];
              String postId = candidateData["postId"];
              int votes = candidateData["votes"];
              String percentage = candidateData["percentage"];

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(candidateName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Votes: $votes | $percentage"),
                  trailing: Text("Post: $postId"),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
