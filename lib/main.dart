import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:the_project/auth_layout.dart';
import 'package:the_project/pages/admin/admin_dashboard_page.dart';
import 'package:the_project/pages/landing_page.dart';
import 'package:the_project/pages/login/login_page.dart';
import 'package:the_project/pages/login/register_page.dart';
import 'package:the_project/pages/students/student_dashboard_page.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBCgcYzy7MhUw_jCuIPGuv_OQSqbq3W71A",
        authDomain: "attendance-project-682d7.firebaseapp.com",
        appId: "1:1077795804592:web:54fbc66783067953f5b275", 
        messagingSenderId: "1077795804592", 
        projectId: "attendance-project-682d7",
        storageBucket: "attendance-project-682d7.firebasestorage.app",
      )
    );
  }

  runApp(MyApp());

}

class MyApp extends StatelessWidget {

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Attendance LFWA",
      theme: ThemeData(
        primarySwatch: Colors.blue
      ),
    
      initialRoute: '/auth',
      routes: {
        '/auth':(context) => AuthLayout(),
        '/':(context) => LandingPage(),
        '/login':(context) => LoginPage(),
        '/register':(context) => RegisterPage(),
        '/admin':(context) => AdminDashboardPage(),
        '/student':(context) => StudentDashboardPage()
      },
      builder: (context, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final currentRoute = ModalRoute.of(context)?.settings.name;
          if (currentRoute != '/auth') {
            Navigator.of(context).pushReplacementNamed('/auth');
          }
        });
        return child!;
      },

    );
  }
}