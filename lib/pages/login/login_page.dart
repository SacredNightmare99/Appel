import 'package:flutter/material.dart';
import 'package:the_project/pages/login/utils/login_button.dart';
import 'package:the_project/pages/login/utils/text_field.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

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
                labelText: "Username",
              ),
              SizedBox(height: 10,),
              MyTextField(
                labelText: "Password",
                obscureText: true,
              ),
              SizedBox(height: 100,),
              LoginButton(
                onPressed: () {},
                text: "Login",
              )
            ],
          ),
      ),
    );
  }
}