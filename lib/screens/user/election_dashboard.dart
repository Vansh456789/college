
import 'package:flutter/material.dart';
import 'nomination_criteria.dart';
import 'nomination_procedure.dart';
import 'other_details.dart';
import 'submit_nominations.dart';
import 'voting_page.dart';
import 'results_page.dart';

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
          children: [
            _buildButton(context, "Nomination Criteria", NominationCriteria(electionId: electionId)),
            _buildButton(context, "Nomination Procedure", NominationProcedure(electionId: electionId)),
            _buildButton(context, "Other Details", OtherDetails(electionId: electionId)),
            _buildButton(context, "Submit Nomination", SubmitNominations(electionId: electionId)),
            _buildButton(context, "Vote", VotingPage(electionId: electionId)),
            _buildButton(context, "Results", ResultsPage(electionId: electionId)),
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
}
