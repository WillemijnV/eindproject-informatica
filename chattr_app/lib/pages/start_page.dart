// dit is de startpagina wanneer er nog niet is ingelogd of geregistreerd

import 'package:flutter/material.dart';

class StartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Chattr',
              style: TextStyle(
                fontSize: 40, 
                fontWeight: FontWeight.bold,
                ),
            ),

            SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: Text("Inloggen"),
                ),

                SizedBox(width: 20),

              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: Text("Registreren")
              ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

