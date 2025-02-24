import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PublishResults extends StatelessWidget {
  final String electionId;

  const PublishResults({required this.electionId, super.key});

  Future<void> _publishResults(BuildContext context) async {
    try {
      QuerySnapshot votesSnapshot = await FirebaseFirestore.instance
          .collection("elections")
          .doc(electionId)
          .collection("votes")
          .get();

      if (votesSnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No votes cast. Cannot publish results.")),
        );
        return;
      }

      Map<String, int> voteCount = {};
      int totalVotes = votesSnapshot.docs.length;

      for (var vote in votesSnapshot.docs) {
        Map<String, dynamic> voteData = vote.data() as Map<String, dynamic>;
        if (voteData.containsKey("candidateId")) {
          String candidateId = voteData["candidateId"];
          voteCount[candidateId] = (voteCount[candidateId] ?? 0) + 1;
        }
      }

      // ✅ Fetch Candidate Details
      Map<String, Map<String, dynamic>> voteResults = {};

      for (var candidateId in voteCount.keys) {
        DocumentSnapshot candidateDoc = await FirebaseFirestore.instance
            .collection("elections")
            .doc(electionId)
            .collection("nominations")
            .doc(candidateId)
            .get();

        if (candidateDoc.exists) {
          Map<String, dynamic> candidateData = candidateDoc.data() as Map<String, dynamic>;
          voteResults[candidateId] = {
            "candidateName": candidateData["candidateName"] ?? "Unknown",
            "postId": candidateData["postId"] ?? "Unknown",
            "votes": voteCount[candidateId] ?? 0,
            "percentage": "${((voteCount[candidateId]! / totalVotes) * 100).toStringAsFixed(2)}%",
          };
        }
      }

      // ✅ Store results in Firestore under `results/{electionId}`
      await FirebaseFirestore.instance.collection("results").doc(electionId).set({
        "resultsPublished": true,
        "voteResults": voteResults,
        "publishedAt": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Election results published successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error publishing results: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Publish Results")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _publishResults(context),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text("Publish Election Results", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
