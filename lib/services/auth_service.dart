import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Prevent multiple admins from signing up
  Future<bool> isAdminExists() async {
    var query = await _firestore.collection("users").where("role", isEqualTo: "admin").get();
    return query.docs.isNotEmpty;
  }

  // Sign up with email and password
  Future<User?> signUp(String name, String email, String rollNo, String phone, String password, String role) async {
    try {
      if (role == "admin" && await isAdminExists()) return null;

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      if (user != null) {
        await _firestore.collection("users").doc(user.uid).set({
          "name": name,
          "email": email,
          "rollNo": rollNo,
          "phone": phone,
          "role": role,
          "createdAt": FieldValue.serverTimestamp(),
        });
      }
      return user;
    } catch (_) {
      return null;
    }
  }

  // Sign in with email and password
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (_) {
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
