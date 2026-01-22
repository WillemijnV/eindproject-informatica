// hier komt het inlogscherm

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chattr_app/app_state.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _gebruikersnaamController = 
    TextEditingController();
  final TextEditingController _wachtwoordController = 
    TextEditingController();
  
  bool _verbergWachtwoord = true;
  bool _laden = false;

  @override
  void dispose() {
    _gebruikersnaamController.dispose();
    _wachtwoordController.dispose();
    super.dispose();
  }

  //Login functie
  Future<void> _login() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _laden = true);

  final success = await loginUser(
    _gebruikersnaamController.text.trim(),
    _wachtwoordController.text,
  );

  setState(() => _laden = false);

  if (!success) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Onjuiste gebruikersnaam of wachtwoord')),
    );
    return;
  }

  // Succesvol ingelogd
  context.read<AppState>().login(
    "123", // later eventueel userId
    _gebruikersnaamController.text.trim(),
  );

  if (mounted) {
    Navigator.pushReplacementNamed(context, '/home');
  }
}


  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar:AppBar(
        title: const Text("Inloggen bij Chattr"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                  "Welkom bij Chattr",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Log in om the chatten",
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 30),

                //Gebruikersnaam
                TextFormField(
                  controller: _gebruikersnaamController,
                  decoration: const InputDecoration(
                    labelText: "Gebruikersnaam",
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Vul je gebruikersnaam in";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                //Wachtwoord
                TextFormField(
                  controller: _wachtwoordController,
                  obscureText: _verbergWachtwoord,
                  decoration: InputDecoration(
                    labelText: "Wachtwoord",
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _verbergWachtwoord
                            ? Icons.visibility_off
                            : Icons.visibility,                                                   
                      ),
                      onPressed: () {
                        setState(() {
                          _verbergWachtwoord = !_verbergWachtwoord;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Vul je wachtwoord in";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 10),

                const SizedBox(height: 10),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text("Wachtwoord vergeten?"),
                  ),
                ),

                const SizedBox(height: 20),

                //Inlog knop
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _laden ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _laden
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text("Inloggen"),
                  ),
                ),

                const SizedBox(height: 20),

                //Naar registreren
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Nog geen account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text("Registreer"),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}