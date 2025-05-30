import 'package:flutter/material.dart';
import 'package:the_project/pages/login/utils/login_button.dart';
import 'package:the_project/pages/login/utils/text_field.dart';
import 'package:the_project/services/authentication_service.dart';

class LoginPage extends StatefulWidget {

  final VoidCallback onLoginSuccess;

  const LoginPage({super.key, required this.onLoginSuccess});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _error;

  void _login() async {
    String? error = await _authService.signIn(
      _emailController.text,
      _passwordController.text,
    );
    if (error == null) {
      widget.onLoginSuccess();
    } else {
      setState(() {
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Login Page"),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
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
              SizedBox(height: 100,),
              LoginButton(
                onPressed: _login,
                text: "Login",
              )
            ],
          ),
      ),
    );
  }
}