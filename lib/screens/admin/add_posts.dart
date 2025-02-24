

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddPosts extends StatefulWidget {
  final String electionId;  // ✅ Required electionId

  const AddPosts({required this.electionId, super.key});

  @override
  _AddPostsState createState() => _AddPostsState();
}


class _AddPostsState extends State<AddPosts> {
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;

  void _addPost() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance
          .collection("elections") // Navigate to elections
          .doc(widget.electionId) // Select the specific election
          .collection("posts") // Add post inside "posts" subcollection
          .add({
            
        "position": _positionController.text.trim(),
        "description": _descriptionController.text.trim(),
        "timestamp": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Post Added Successfully!")),
      );

      _positionController.clear();
      _descriptionController.clear();
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
      appBar: AppBar(title: const Text("Add Posts")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(_positionController, "Position"),
            _buildTextField(_descriptionController, "Description"),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _addPost,
                    child: const Text("Add Post"),
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
          fillColor: Colors.purple.withOpacity(0.1),
          filled: true,
        ),
      ),
    );
  }
}

