
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_posts.dart';

class SelectElection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Election")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('elections').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          var elections = snapshot.data!.docs;
          return ListView.builder(
            itemCount: elections.length,
            itemBuilder: (context, index) {
              var election = elections[index];

              return ListTile(
                title: Text(election['title']),
                subtitle: Text("Start: ${election['startDate']} - End: ${election['endDate']}"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddPosts(electionId: election.id),  // ✅ Pass electionId
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}


