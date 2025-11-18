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
        title: Text("Welkom, ${state.userName}"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              state.logout();
              Navigator.pushReplacementNamed(
                context,
                MaterialPageRoute(builder: (_) => StartPage()) as String,
                );
            },
          ),
        ],
      ),
      body: Center(
        child: Text("Dit wordt je chat lijst"),
      ),
    );
  }
}
