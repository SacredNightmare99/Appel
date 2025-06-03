import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:the_project/services/auth_service.dart';

class AuthLayout extends StatelessWidget {
  
  final Widget? pageIfNotConnected;
  
  const AuthLayout({
    super.key,
    this.pageIfNotConnected,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: authService,
      builder: (context, authService, child) {
        return StreamBuilder(
          stream: authService.authStateChanges,
          builder: (context, snapshot) {

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            WidgetsBinding.instance.addPostFrameCallback((_) async {
              
              if (snapshot.hasData) {
                final user = snapshot.data;
                final userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.email).get();

                final role = userDoc.data()?['role'] ?? 'member';

                if (role == 'admin') {
                  Navigator.pushReplacementNamed(context, '/admin');
                } else {
                  Navigator.pushReplacementNamed(context, '/student');
                }
              } else {
                Navigator.pushReplacementNamed(context, '/');
              }

            });

            return SizedBox();
          },
        );
      }
    );
  }
}