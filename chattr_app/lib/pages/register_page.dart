import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registreren'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.always,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Volledige naam',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vul alstublieft uw naam in';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                    labelText: 'E-mailadres',
                ),
                validator: (value) {
                   if (value == null || value.isEmpty) {
                    return 'Vul alstublieft uw naam in';
                  }
                  return null; 
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Alle velden zijn geldig
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Formulier is geldig!')),
                    );
                  }
                },
                child: const Text('Indienen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}