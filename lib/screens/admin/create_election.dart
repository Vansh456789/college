

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/common_layout.dart';

class CreateElection extends StatefulWidget {
  const CreateElection({super.key});

  @override
  _CreateElectionState createState() => _CreateElectionState();
}

class _CreateElectionState extends State<CreateElection> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  bool _isLoading = false;

  void _createElection() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection("elections").add({
        "title": _titleController.text.trim(),
        "description": _descriptionController.text.trim(),
        "startDate": _startDateController.text.trim(),
        "endDate": _endDateController.text.trim(),
        "status": "upcoming",
        "createdAt": FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Election Created Successfully!")),
      );
      _titleController.clear();
      _descriptionController.clear();
      _startDateController.clear();
      _endDateController.clear();
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
      title: "Create Election",
      child: Column(
        children: [
          _buildTextField(_titleController, "Election Title"),
          _buildTextField(_descriptionController, "Description"),
          _buildTextField(_startDateController, "Start Date (YYYY-MM-DD)"),
          _buildTextField(_endDateController, "End Date (YYYY-MM-DD)"),
          const SizedBox(height: 20),
          _isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _createElection,
                  child: const Text("Create Election"),
                ),
        ],
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
          fillColor: Colors.purple.withOpacity(0.1),
          filled: true,
        ),
      ),
    );
  }
}


