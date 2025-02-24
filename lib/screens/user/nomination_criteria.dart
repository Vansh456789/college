
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NominationCriteria extends StatelessWidget {
  final String electionId;

  const NominationCriteria({required this.electionId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nomination Criteria")),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection("elections").doc(electionId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          var electionData = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(electionData["nominationCriteria"] ?? "No criteria available."),
          );
        },
      ),
    );
  }
}
