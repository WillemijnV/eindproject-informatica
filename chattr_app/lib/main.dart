// hier komen alle routes tussen verschillende schermen te staan en functies etc die voor alles gelden

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'pages/main_home_page.dart';
import 'pages/start_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: 'Chattr',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 13, 11, 105),
            brightness: Brightness.dark,
            ),

            scaffoldBackgroundColor: Color.fromARGB(255, 20, 19, 83),
        ),
        
        home: StartPage(),

        routes: {
          '/login': (context) => LoginPage(),
          '/register': (context) => RegisterPage(),
          '/home': (context) => MainHomePage(),
        }
      ),
    );
  }
}



