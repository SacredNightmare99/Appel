import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:the_project/controllers/user_controller.dart';
import 'package:the_project/backend/auth/user.dart';

class AuthService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  // Sign in with email and password
  Future<AuthResponse> signInWithEmailAndPassword(String email, String password) async {
    final response = await _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password
    );

    final user = CurrentUser(email: email, uuid: _supabaseClient.auth.currentUser!.id);
    Get.find<UserController>().setUser(user);

    return response;
  }

  // Sign Out
  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  // Get current user ID (UID)
  String? getCurrentUserId() {
    return _supabaseClient.auth.currentUser?.id;
  }

}