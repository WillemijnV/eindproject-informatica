// hier komen alle routes tussen verschillende schermen te staan en functies etc die voor alles gelden

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'chat_state.dart';
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => ChatState()),
      ],
      child: MaterialApp(
        title: 'Chattr',
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Color.fromARGB(255, 20, 19, 83),

          appBarTheme: const AppBarTheme(
            backgroundColor: Color.fromARGB(255, 19, 18, 75),
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              color: Colors.amber,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            iconTheme: IconThemeData(color: Colors.amber),
          ),

          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.amber,
            brightness: Brightness.dark,
            primary: Colors.amber,
          ),

          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: Colors.white),
            bodyLarge: TextStyle(color: Colors.white),
          ),

          inputDecorationTheme: InputDecorationTheme(
            labelStyle: const TextStyle(color: Colors.amber),
            prefixIconColor: Colors.amber,
            suffixIconColor: Colors.amber,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.amber),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.amber, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors.amber,
            ),
          ),
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
