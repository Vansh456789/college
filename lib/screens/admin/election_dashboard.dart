import 'package:flutter/material.dart';
import 'add_posts.dart';
import 'view_posts.dart';
import 'float_nominations.dart';
import 'approve_nominations.dart';
import 'final_candidates.dart';
import 'monitor_elections.dart';
import 'publish_results.dart';

class ElectionDashboard extends StatelessWidget {
  final String electionId;
  final String electionTitle;

  const ElectionDashboard({required this.electionId, required this.electionTitle, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(electionTitle)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildButton(context, "Add Posts", AddPosts(electionId: electionId)),
            _buildButton(context, "View Posts", ViewPosts(electionId: electionId)),
            _buildButton(context, "Float Nominations", FloatNominations(electionId: electionId)),
            _buildButton(context, "Approve Nominations", ApproveNominations(electionId: electionId)),
            _buildButton(context, "View Final Candidates", FinalCandidates(electionId: electionId)),
            _buildButton(context, "Monitor Elections", MonitorElections(electionId: electionId)),
            _buildButton(context, "Publish Results", PublishResults(electionId: electionId)),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, Widget page) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ElevatedButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
