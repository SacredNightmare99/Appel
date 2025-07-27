import 'dart:developer' as devtools;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:the_project/backend/auth/auth_gate.dart';
import 'package:the_project/backend/auth/auth_service.dart';

class LoginController extends GetxController {
  final AuthService authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  var obscurePass = true.obs;
  var errorMsg = RxnString();
  var isLoading = false.obs;

  void toggleObscurePass() {
    obscurePass.value = !obscurePass.value;
  }

  void login() async {
    if (formKey.currentState!.validate()) {
      isLoading.value = true;
      errorMsg.value = null;

      final email = emailController.text;
      final password = passwordController.text;

      try {
        await authService.signInWithEmailAndPassword(email, password);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAll(() => const AuthGate());
        });
      } on AuthApiException catch (authexception) {
        devtools.log(authexception.toString());
        if (authexception.message.toLowerCase().contains('invalid login credentials')) {
          errorMsg.value = 'Incorrect email or password';
        } else if (authexception.message.toLowerCase().contains('email not confirmed')) {
          errorMsg.value = 'Email not verified';
        } else {
          errorMsg.value = 'Authentication failed';
        }
      } catch (e) {
        devtools.log(e.toString());
        errorMsg.value = "An unexpected error occurred.";
      } finally {
        isLoading.value = false;
      }
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
