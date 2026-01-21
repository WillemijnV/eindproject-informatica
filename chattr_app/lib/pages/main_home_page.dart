// hier komt het hoofdscherm wanneer je ingelogd bent en blijft, je ziet hier een contactenlijst etc.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:chattr_app/app_state.dart';
import 'start_page.dart';
import 'chat_page.dart';

class MainHomePage extends StatefulWidget {
  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  List<String> contacts = ['Anna', 'Bram', 'Clara'];

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

      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              child: Text(contacts[index][0]),
            ),
            title: Text(contacts[index]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatPage(
                    contactName: contacts[index],
                  ),
                ),
              );
            },
          );
        },
      ),

      //nieuwe chat button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatPage(contactName: "Nieuwe chat"),
            ),
          );
        },
        backgroundColor: Colors.amber,
        child: Icon(Icons.chat, color: Colors.black),
      ),
    );
  }
}
