import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubmitNominations extends StatefulWidget {
  final String electionId;

  const SubmitNominations({required this.electionId, super.key});

  @override
  _SubmitNominationsState createState() => _SubmitNominationsState();
}

class _SubmitNominationsState extends State<SubmitNominations> {
  final TextEditingController _candidateNameController = TextEditingController();
  String? _selectedPostId;
  bool _isLoading = false;

  void _submitNomination() async {
    if (_selectedPostId == null || _candidateNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your name and select a post!")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance
          .collection("elections")
          .doc(widget.electionId)
          .collection("nominations")
          .add({
        "candidateName": _candidateNameController.text.trim(),
        "postId": _selectedPostId,
        "status": "pending",
        "createdAt": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nomination Submitted Successfully!")),
      );
      _candidateNameController.clear();
      setState(() => _selectedPostId = null);
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
      appBar: AppBar(title: const Text("Submit Nomination")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _candidateNameController,
                decoration: InputDecoration(
                  hintText: "Enter Your Name",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("elections")
                    .doc(widget.electionId)
                    .collection("posts")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const CircularProgressIndicator();

                  var posts = snapshot.data!.docs;

                  if (posts.isEmpty) {
                    return const Text("No posts available for this election.");
                  }

                  return DropdownButtonFormField<String>(
                    
  value: _selectedPostId,
  onChanged: (value) => setState(() => _selectedPostId = value),
  items: posts.map((post) {
    Map<String, dynamic> postData = post.data() as Map<String, dynamic>;  // ✅ Explicit casting
    String position = postData.containsKey("position") ? postData["position"] : "Unknown Position"; 

    return DropdownMenuItem<String>(
      value: post.id,
      child: Text(position),
    );
  }).toList(),
  decoration: const InputDecoration(
    labelText: "Select a Post",
    border: OutlineInputBorder(),
  ),
);

                },
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitNomination,
                      child: const Text("Submit Nomination"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
