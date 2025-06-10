// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:the_project/auth/utils/login_button.dart';
import 'package:the_project/auth/utils/text_field.dart';

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
                onPressed: () {}, 
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