import 'package:flutter/material.dart';
import 'package:to_do_list/login_screen.dart';
import 'package:to_do_list/splash_screen.dart';
import 'package:to_do_list/dashboard.dart';
import 'package:to_do_list/tambah_tugas_screen.dart';
import 'package:to_do_list/register_screen.dart';
import 'package:to_do_list/tambah_tugas.dart';
import 'package:to_do_list/edit_tugas.dart';
import 'package:to_do_list/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}


