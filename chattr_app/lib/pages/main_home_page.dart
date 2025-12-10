// hier komt het hoofdscherm wanneer je ingelogd bent en blijft, je ziet hier een contactenlijst etc.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:chattr_app/app_state.dart';

import 'start_page.dart';

class MainHomePage extends StatefulWidget {
  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Welkom, ${state.userName}", style: TextStyle(color: Colors.amber)),
        backgroundColor: const Color.fromARGB(255, 19, 18, 75),
        actions: [
          TextButton.icon(
            onPressed: () {
              state.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => StartPage()),
              );
            },
            icon: Icon(Icons.logout, color: Colors.amber),
            label: Text('Uitloggen', style: TextStyle(color: Colors.amber))
          ),
        ],
      ),
      body: Center(
        child: Text("Dit wordt je chat lijst"),
      ),
    );
  }
}
