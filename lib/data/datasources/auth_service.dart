import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
    String? profilePic,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user != null) {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(credential.user!.uid)
          .set({
        'uid': credential.user!.uid,
        'name': name,
        'email': email,
        'profilePic': profilePic ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return credential;
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> updateProfile({String? name, String? profilePic}) async {
    final user = _auth.currentUser;
    if (user != null) {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (profilePic != null) updates['profilePic'] = profilePic;

      if (updates.isNotEmpty) {
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .update(updates);
      }
    }
  }

  Future<DocumentSnapshot> getUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      return await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();
    }
    throw Exception('User not logged in');
  }
}
