import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MonitorElections extends StatefulWidget {
  final String electionId;

  const MonitorElections({required this.electionId, super.key});

  @override
  _MonitorElectionsState createState() => _MonitorElectionsState();
}

class _MonitorElectionsState extends State<MonitorElections> {
  bool _isVotingPaused = false;
  bool _electionEnded = false;

  @override
  void initState() {
    super.initState();
    _getElectionStatus();
  }

  /// ✅ Fetches Voting & Election Status
  Future<void> _getElectionStatus() async {
    DocumentSnapshot electionDoc =
        await FirebaseFirestore.instance.collection("elections").doc(widget.electionId).get();

    if (electionDoc.exists) {
      setState(() {
        _isVotingPaused = electionDoc["votingPaused"] ?? false;
        _electionEnded = electionDoc["electionEnded"] ?? false;
      });
    }
  }

  /// ✅ Toggle Voting On/Off
  void _toggleVoting() async {
    setState(() => _isVotingPaused = !_isVotingPaused);
    await FirebaseFirestore.instance.collection("elections").doc(widget.electionId).update({
      "votingPaused": _isVotingPaused,
    });
  }

  /// ✅ End Election
  void _endElection() async {
    setState(() => _electionEnded = true);
    await FirebaseFirestore.instance.collection("elections").doc(widget.electionId).update({
      "electionEnded": true,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Election has ended! Results can now be published.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Monitor Elections")),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _toggleVoting,
            child: Text(_isVotingPaused ? "Resume Voting" : "Pause Voting"),
          ),
          ElevatedButton(
            onPressed: _electionEnded ? null : _endElection,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("End Election"),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("elections")
                  .doc(widget.electionId)
                  .collection("votes")
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                var votes = snapshot.data!.docs;
                if (votes.isEmpty) {
                  return const Center(child: Text("No votes cast yet."));
                }

                return ListView.builder(
                  itemCount: votes.length,
                  itemBuilder: (context, index) {
                    var vote = votes[index];
                    Map<String, dynamic> voteData = vote.data() as Map<String, dynamic>;

                    /// ✅ Check if `userId` & `candidateId` exist to prevent error
                    String voter = voteData.containsKey("userId") ? voteData["userId"] : "Unknown Voter";
                    String candidate =
                        voteData.containsKey("candidateId") ? voteData["candidateId"] : "Unknown Candidate";

                    return ListTile(
                      title: Text("Voter: $voter"),
                      subtitle: Text("Candidate: $candidate"),
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
