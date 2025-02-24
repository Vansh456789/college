
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FloatNominations extends StatefulWidget {
  final String electionId;

  const FloatNominations({required this.electionId, super.key});

  @override
  _FloatNominationsState createState() => _FloatNominationsState();
}

class _FloatNominationsState extends State<FloatNominations> {
  final TextEditingController _criteriaController = TextEditingController();
  final TextEditingController _procedureController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  bool _isLoading = false;

  void _submitDetails() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection("elections").doc(widget.electionId).update({
        "nominationCriteria": _criteriaController.text.trim(),
        "nominationProcedure": _procedureController.text.trim(),
        "otherDetails": _detailsController.text.trim(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nomination details updated successfully!")),
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
    return Scaffold(
      appBar: AppBar(title: const Text("Float Nominations")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(_criteriaController, "Nomination Criteria"),
            _buildTextField(_procedureController, "Nomination Procedure"),
            _buildTextField(_detailsController, "Other Details"),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submitDetails,
                    child: const Text("Float Nominations"),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }


}

