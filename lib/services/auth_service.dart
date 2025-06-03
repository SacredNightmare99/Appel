
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:the_project/services/firestore_service.dart';

ValueNotifier<AuthService> authService = ValueNotifier(AuthService());

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  User? get currenUser => firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  final FirestoreService firestoreService = FirestoreService();

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password
    );
  }

  Future<UserCredential> createAccount({
    required String email,
    required String password,
  }) async {

    await firestoreService.assignRole(email, 'member');

    return await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password
    );
  }

  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  Future<void> resetPassword({
    required String email,
  }) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> updateUsername({
    required String username,
  }) async {
    await currenUser!.updateDisplayName(username);
  }

  Future<void> deleteAccount({
    required String email,
    required String password,
  }) async {
    AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
    await currenUser!.reauthenticateWithCredential(credential);
    await currenUser!.delete();
    await firebaseAuth.signOut();
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String email,
  }) async {
    AuthCredential credential = EmailAuthProvider.credential(email: email, password: currentPassword);
    await currenUser!.reauthenticateWithCredential(credential);
    await currenUser!.updatePassword(newPassword);
  }

  Future<UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      // Web flow
      GoogleAuthProvider googleProvider = GoogleAuthProvider();

      return await firebaseAuth.signInWithPopup(googleProvider);
    } else {
      // Mobile flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Sign in aborted by user',
        );
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await firebaseAuth.signInWithCredential(credential);
    }
  }

}
