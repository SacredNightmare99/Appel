
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
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
  }

  Future<void> resetPassword({
    required String email,
  }) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> updateUsername({required String username}) async {
    if (currenUser != null) {
      await currenUser!.updateDisplayName(username);
      await currenUser!.reload();
    }
  }

   Future<void> deleteAccount({
    required String email,
    required String password,
  }) async {
    final user = currenUser;

    if (user == null) throw FirebaseAuthException(code: 'no-user', message: 'No user signed in');

    if (!kIsWeb) {
      // Native reauthentication
      final credential = EmailAuthProvider.credential(email: email, password: password);
      await user.reauthenticateWithCredential(credential);
    } else {
      // On Web, reauth may not be needed if user recently signed in.
      // Firebase Web SDK will throw if reauth is needed.
      debugPrint('⚠️ Reauthentication on Web skipped (limited support)');
    }

    await user.delete();
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String email,
  }) async {
    final user = currenUser;

    if (user == null) throw FirebaseAuthException(code: 'no-user', message: 'No user signed in');

    if (!kIsWeb) {
      final credential = EmailAuthProvider.credential(email: email, password: currentPassword);
      await user.reauthenticateWithCredential(credential);
    } else {
      debugPrint('⚠️ Reauthentication on Web skipped (limited support)');
    }

    await user.updatePassword(newPassword);
  }

  Future<UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();

      return await firebaseAuth.signInWithPopup(googleProvider);
    } else {
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
