import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:the_project/controllers/ai_chat_controller.dart';
import 'package:the_project/controllers/attendance_controller.dart';
import 'package:the_project/controllers/batch_controller.dart';
import 'package:the_project/controllers/student_controller.dart';
import 'package:the_project/shell_page.dart';
import 'package:the_project/utils/colors.dart';
import 'package:the_project/widgets/custom_navbar.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  await Supabase.initialize(
    url: dotenv.env['SupabaseURL']!,
    anonKey: dotenv.env['SupabaseAPI']!
  );

  Get.put(NavController());
  Get.put(StudentController());
  Get.put(AttendanceController());
  Get.put(BatchController());
  Get.put(AiChatController());
  runApp(MyApp());

}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Appel",
      debugShowCheckedModeBanner: false,
      theme: ThemeData.from(colorScheme: ColorScheme.fromSeed(seedColor: AppColors.frenchBlue)),
      home: ShellPage(),
    );
  }
}