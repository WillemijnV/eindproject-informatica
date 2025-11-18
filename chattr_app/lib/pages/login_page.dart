// hier komt het inlogscherm

//minimale om te kijken of de app werkt
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chattr_app/app_state.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Inloggen")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // tijdelijke neppe login zodat het werkt
            context.read<AppState>().login("123", "TestUser");
            Navigator.pushReplacementNamed(context, '/home');
          },
          child: Text("Inloggen (tijdelijk)"),
        ),
      ),
    );
  }
}
