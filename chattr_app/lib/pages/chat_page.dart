//herbruikbare chatpagina voor het chatten met contacten

import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  final String contactName;
  ChatPage({required this.contactName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(contactName),
        backgroundColor: const Color.fromARGB(255, 19, 18, 75),
      ),
      body: Column(
        children: [
          //hier komt de chatlijst
          Expanded(
            child: Center(
              child: Text(
                "Hier komen de berichten met $contactName", 
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),

          //typen van bericht
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Typ hier je bericht...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () { 
                    //hier komt later de functie om berichten te versturen
                   },
                  child: Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}