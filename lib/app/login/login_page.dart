// ignore_for_file: unused_field

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_project/app/login/utils/login_button.dart';
import 'package:the_project/app/login/utils/text_field.dart';
import 'package:the_project/services/auth_service.dart';

class LoginPage extends StatefulWidget {

  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String errorMessage = "";

  void login() async {
    try {
      await authService.value.signIn(email: _emailController.text, password: _passwordController.text);
      _emailController.clear();
      _passwordController.clear();
      Navigator.pushReplacementNamed(context, '/auth');
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message ?? "There is an error";
      });
    }
  }

  void loginGoogle() async {
    try {
      await authService.value.signInWithGoogle();
      Navigator.pushReplacementNamed(context, '/auth');
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message ?? "There is an error";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Login"),
        automaticallyImplyLeading: true,
      ),
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 100,),
              MyTextField(
                labelText: "Email",
                controller: _emailController,
              ),
              SizedBox(height: 10,),
              MyTextField(
                labelText: "Password",
                obscureText: true,
                controller: _passwordController,
              ),
              SizedBox(height: 10,),
              Text(errorMessage, style: TextStyle(color: Colors.red),),
              SizedBox(height: 10,),
              IconButton(
                onPressed: loginGoogle, 
                icon: Icon(Icons.g_mobiledata_rounded, size: 30,)
              ),
              SizedBox(height: 100,),
              LoginButton(
                onPressed: login,
                text: "Login",
              )
            ],
          ),
      ),
    );
  }
}