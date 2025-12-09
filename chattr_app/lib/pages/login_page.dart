// hier komt het inlogscherm

//minimale om te kijken of de app werkt
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chattr_app/app_state.dart';

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

  //Wachtwoord regels
  bool hasUppercase = false;
  bool hasLowercase = false;
  bool hasNumber = false;
  bool hasSpecialChar = false;
  bool hasMinLength = false;

  //Wachtwoord controleren
  void _checkPassword(String value) {
    setState(() {
      hasUppercase = value.contains(RegExp(r'[A-Z]'));
      hasLowercase = value.contains(RegExp(r'[a-z]'));
      hasNumber = value.contains(RegExp(r'[0-9]'));
      hasSpecialChar = value.contains(RegExp(r'[!@#\$%^&*(),.?{}|<>/]'));
      hasMinLength = value.length >= 8;
    });
  }

  @override
  void dispose() {
    _gebruikersnaamController.dispose();
    _wachtwoordController.dispose();
    super.dispose();
  }

  //Login functie
  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _laden = true);
    await Future.delayed(const Duration(milliseconds: 800));

    context.read<AppState>().login(
      "123",
      _gebruikersnaamController.text,
    );

    setState(() => _laden = false);

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  //Widget controle
  Widget _wachtwoordCheck(String text, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.cancel,
          color: isValid ? Colors.green : Colors.red,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
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
                  onChanged: _checkPassword,
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
                    if (!hasUppercase ||
                        !hasLowercase ||
                        !hasNumber ||
                        !hasSpecialChar ||
                        !hasMinLength) {
                      return "Wachtwoord is niet sterk genoeg";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 10),

                //Wachtwoord regels
                _wachtwoordCheck("Minimaal 8 tekens", hasMinLength),
                _wachtwoordCheck("Minstens 1 hoofdletter", hasUppercase),
                _wachtwoordCheck("Minstens 1 kleine letter", hasLowercase),
                _wachtwoordCheck("Minstens 1 cijfer", hasNumber),
                _wachtwoordCheck("Minstens 1 speciaal teken", hasSpecialChar),

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