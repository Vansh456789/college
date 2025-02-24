import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/common_layout.dart';

class VotingPage extends StatefulWidget {
  final String electionId;

  const VotingPage({required this.electionId, super.key});

  @override
  _VotingPageState createState() => _VotingPageState();
}

class _VotingPageState extends State<VotingPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  Map<String, String?> _votedCandidates = {}; // ✅ Ensuring non-null map
  bool _isVotingPaused = false;

  @override
  void initState() {
    super.initState();
    _checkIfVoted();
    _getVotingStatus();
  }

  /// ✅ Checks if the user has already voted for any posts.
  Future<void> _checkIfVoted() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    QuerySnapshot voteSnapshot = await FirebaseFirestore.instance
        .collection("elections")
        .doc(widget.electionId)
        .collection("votes")
        .where("userId", isEqualTo: user.uid)
        .get();

    if (voteSnapshot.docs.isNotEmpty) {
      setState(() {
        for (var vote in voteSnapshot.docs) {
          _votedCandidates[vote["postId"]] = vote["candidateId"];
        }
      });
    }
  }

  /// ✅ Fetches voting status (Paused or Active).
  Future<void> _getVotingStatus() async {
    DocumentSnapshot electionDoc = await FirebaseFirestore.instance
        .collection("elections")
        .doc(widget.electionId)
        .get();

    if (electionDoc.exists) {
      setState(() {
        _isVotingPaused = electionDoc["votingPaused"] ?? false;
      });
    }
  }

  /// ✅ Handles voting logic, ensuring one vote per post.
  void _vote(String postId, String candidateId) async {
    if (_votedCandidates.containsKey(postId) && _votedCandidates[postId] != null) {  // ✅ Fix applied
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You have already voted for this post!")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance
          .collection("elections")
          .doc(widget.electionId)
          .collection("votes")
          .add({
        "userId": _auth.currentUser!.uid,
        "postId": postId,
        "candidateId": candidateId,
        "timestamp": FieldValue.serverTimestamp(),
      });

      setState(() => _votedCandidates[postId] = candidateId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vote Cast Successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      title: "Vote Now",
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("elections")
            .doc(widget.electionId)
            .collection("posts")
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();

          var posts = snapshot.data!.docs;

          if (posts.isEmpty) {
            return const Center(child: Text("No available posts to vote for."));
          }

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              var post = posts[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: ExpansionTile(
                  title: Text(post["position"] ?? "Unknown Position"),
                  children: [
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("elections")
                          .doc(widget.electionId)
                          .collection("nominations") // ✅ Using approved nominations
                          .where("postId", isEqualTo: post.id)
                          .where("status", isEqualTo: "approved") // ✅ Fetch only approved candidates
                          .snapshots(),
                      builder: (context, candidateSnapshot) {
                        if (!candidateSnapshot.hasData) {
                          return const CircularProgressIndicator();
                        }

                        var candidates = candidateSnapshot.data!.docs;

                        if (candidates.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(10),
                            child: Text("No candidates available for this post."),
                          );
                        }

                        return Column(
                          children: candidates.map((candidate) {
                            return ListTile(
                              title: Text(candidate["candidateName"] ?? "Unknown"),
                              trailing: _votedCandidates.containsKey(post.id) && _votedCandidates[post.id] == candidate.id
                                  ? const Icon(Icons.check_circle, color: Colors.green)
                                  : ElevatedButton(
                                      onPressed: _isVotingPaused || _isLoading
                                          ? null
                                          : () => _vote(post.id, candidate.id),
                                      child: const Text("Vote"),
                                    ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
