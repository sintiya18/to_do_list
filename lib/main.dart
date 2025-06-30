import 'package:flutter/material.dart';
import 'package:to_do_list/login_screen.dart';
import 'package:to_do_list/splash_screen.dart';
import 'package:to_do_list/dashboard.dart';
import 'package:to_do_list/tambah_tugas_screen.dart';
import 'package:to_do_list/register_screen.dart';
import 'package:to_do_list/profil.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: RegisterScreen(),
    );
  }
}
