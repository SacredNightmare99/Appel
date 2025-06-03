import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_project/pages/login/utils/login_button.dart';
import 'package:the_project/pages/login/utils/text_field.dart';
import 'package:the_project/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String errorMessage = "";

  void register() async {
    try {
      await authService.value.createAccount(
        email: _emailController.text,
        password: _passwordController.text,
      );
      Navigator.of(context).pop();
      _emailController.clear();
      _passwordController.clear();
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
        title: Text("Register"),
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
              SizedBox(height: 100,),
              LoginButton(
                onPressed: register,
                text: "Register",
              )
            ],
          ),
      ),
    );
  }
}