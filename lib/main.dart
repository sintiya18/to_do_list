import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


import 'splash_screen.dart';
import 'dashboard.dart';
import 'edit_tugas.dart';
import 'login_screen.dart';
import 'tambah_tugas.dart';
import 'profil.dart';
import 'notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://zxaflrnnghmwicdtdjsm.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp4YWZscm5uZ2htd2ljZHRkanNtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE3ODU3ODksImV4cCI6MjA2NzM2MTc4OX0.KDA_6K8mfkAkreUncEd-ivpbsYGSii6zA2H_PY7TD-g',
  );
  
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
