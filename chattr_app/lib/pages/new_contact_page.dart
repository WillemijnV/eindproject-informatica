import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chattr_app/chat_state.dart';
import 'package:chattr_app/services/auth_service.dart';
import 'package:chattr_app/pages/chat_page.dart';

class NewContactPage extends StatefulWidget{
  const NewContactPage({super.key});

  @override
  State<NewContactPage> createState() => _NewContactPageState();
}

class _NewContactPageState extends State<NewContactPage> {
  List<String> contacts = [];

  @override
  void initState() {
    super.initState();
    loadContacts();
  }

  Future<void> loadContacts() async {
    final allContacts = await getAvailableContacts(context);
    setState(() {
      contacts = allContacts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nieuwe chat')),
      body: contacts.isEmpty
      ? const Center(child: Text('Geen contacten beschikbaar'))
      : ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          return ListTile(
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
    );
  }
}

//Functie om beschikbare contacten op te halen
Future<List<String>> getAvailableContacts(BuildContext context) async {
  final chatState = context.read<ChatState>();
  final currentUser = chatState.currentUser;

  if (currentUser == null) return [];

  final allUsers = getAllUsers().map((u) => u['username'].toString()).toList();

  //Filter huidige gebruiker eruit
  final available = allUsers.where((u) => u != currentUser).toList();
  return available;
}