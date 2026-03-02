// hier komt het hoofdscherm wanneer je ingelogd bent en blijft, je ziet hier een contactenlijst etc.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:chattr_app/app_state.dart';
import 'chat_page.dart';
import 'instellingen.dart';
import 'new_contact_page.dart';

class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key});
  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final chatState = context.watch<ChatState>();
    final contacts = chatState.getActiveContacts();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Welkom, ${state.userName}", 
          style: TextStyle(color: Colors.amber)
        ),
        backgroundColor: const Color.fromARGB(255, 19, 18, 75),
        actions: [
          TextButton.icon(
            onPressed: () {
                context;
                MaterialPageRoute(
                  builder: (context) => Instellingen()
                ),
              ),
            },
            icon: Icon(Icons.settings, color: Colors.amber),
            label: Text('Instellingen', style: TextStyle(color: Colors.amber))
          ),
        ],
      ),

      body: contacts.isEmpty
          ? const Center(child: Text('Geen contacten beschikbaar'))
          : ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(contact[0]),
                ),
                title: Text(contact),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatPage(contactName: contact),
                    ),
                  );
                },
              );
            },
          ),

      //nieuwe chat button
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        child: Icon(Icons.chat, color: Colors.black),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const NewContactPage()),
          );
        },
      ),
    );
  }
}
