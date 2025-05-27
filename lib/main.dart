import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:the_project/pages/admin/admin_dashboard_page.dart';
import 'package:the_project/pages/login/login_page.dart';

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
      title: "The Project",
      theme: ThemeData(
        primarySwatch: Colors.blue
      ),
      
      initialRoute: '/admin',
      routes: {
        '/login':(context) => LoginPage(),
        '/admin':(context) => AdminDashboardPage(),
      },

    );
  }
}