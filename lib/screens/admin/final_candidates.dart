
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FinalCandidates extends StatelessWidget {
  final String electionId;

  const FinalCandidates({required this.electionId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Final Candidates")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("elections")
            .doc(electionId)
            .collection("nominations")
            .where("status", isEqualTo: "approved")
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var candidates = snapshot.data!.docs;

          return candidates.isEmpty
              ? const Center(child: Text("No approved candidates."))
              : ListView.builder(
                  itemCount: candidates.length,
                  itemBuilder: (context, index) {
                    var candidate = candidates[index];
                    return ListTile(
                      title: Text(candidate["candidateName"]),
                      subtitle: Text("Post ID: ${candidate["postId"]}"),
                      leading: const Icon(Icons.person, color: Colors.purple),
                    );
                  },
                );
        },
      ),
    );
  }
}

