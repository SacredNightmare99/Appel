import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:the_project/auth_layout.dart';
import 'package:the_project/app/admin/admin_dashboard_page.dart';
import 'package:the_project/app/landing_page.dart';
import 'package:the_project/app/login/login_page.dart';
import 'package:the_project/app/login/register_page.dart';
import 'package:the_project/app/students/student_dashboard_page.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: dotenv.env['API_KEY']!,
        authDomain: dotenv.env['Auth_Domain']!,
        appId: dotenv.env['App_Id']!, 
        messagingSenderId: dotenv.env['Messaging_Sender_Id']!, 
        projectId: dotenv.env['Project_Id']!,
        storageBucket: dotenv.env['Storage_Bucket']!,
      )
    );
  }

  runApp(MyApp());

}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Attendance LFWA",
      initialRoute: '/auth',
      routes: {
        '/auth':(context) => AuthLayout(),
        '/':(context) => LandingPage(),
        '/login':(context) => LoginPage(),
        '/register':(context) => RegisterPage(),
        '/admin':(context) => AdminDashboardPage(),
        '/student':(context) => StudentDashboardPage()
      }

    );
  }
}