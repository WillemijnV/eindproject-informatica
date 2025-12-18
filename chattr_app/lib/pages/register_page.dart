import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _naamController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefoonController = TextEditingController();
  final TextEditingController _gebruikersnaamController = TextEditingController();
  final TextEditingController _wachtwoordController = TextEditingController();

  bool _verbergWachtwoord = true;

  // Wachtwoord regels
  bool hasUppercase = false;
  bool hasLowercase = false;
  bool hasNumber = false;
  bool hasSpecialChar = false;
  bool hasMinLength = false;

  void _checkPassword(String value) {
    setState(() {
      hasUppercase = value.contains(RegExp(r'[A-Z]'));
      hasLowercase = value.contains(RegExp(r'[a-z]'));
      hasNumber = value.contains(RegExp(r'[0-9]'));
      hasSpecialChar = value.contains(RegExp(r'[!@#\$%^&*(),.?{}|<>/]'));
      hasMinLength = value.length >= 8;
    });
  }

  Widget _wachtwoordCheck(String text, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.cancel,
          color: isValid ? Colors.green : Colors.red,
          size : 18,
        ),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }

  @override
  void dispose() {
    _naamController.dispose();
    _emailController.dispose();
    _telefoonController.dispose();
    _gebruikersnaamController.dispose();
    _wachtwoordController.dispose();
    super.dispose();
  }

  void _register() {
    if (!_formKey.currentState!.validate()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registratie gelukt!')),
    );

    Navigator.pushReplacementNamed(context, '/login');
  }

    @override
    Widget build(BuildContext context) {
      final colors = Theme.of(context).colorScheme;

      return Scaffold(
        appBar: AppBar(
          title: const Text('Registreren'),
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
                    "Maak een account aan",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Volledige naam
                  TextFormField(
                    controller: _naamController,
                    decoration: const InputDecoration(
                      labelText: "Volledige naam",
                      prefixIcon: Icon(Icons.badge_outlined),
                      border: OutlineInputBorder(),                  
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty
                            ? "Vul je naam in"
                            : null,
                  ),

                  const SizedBox(height: 16),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: "Emailadres",
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty
                            ? "Vul je email in"
                            : null,
                  ),

                  const SizedBox(height: 16),

                  // Telefoon
                  TextFormField(
                    controller: _telefoonController,
                    decoration: const InputDecoration(
                      labelText: "Telefoonnummer",
                      prefixIcon: Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(),
                    ),
                   validator: (value) =>
                        value == null || value.isEmpty
                            ? "Vul je telefoonnummer in"
                            : null,
                 ),

                  const SizedBox(height: 16),

                  // Gebruikersnaam
                  TextFormField(
                    controller: _gebruikersnaamController,
                    decoration: const InputDecoration(
                      labelText: "Gebruikersnaam",
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                   validator: (value) =>
                        value == null || value.isEmpty
                            ? "Vul een gebruikersnaam in"
                            : null,
                  ),

                  const SizedBox(height: 16),

                  // Wachtwoord
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
                        return "Vul een wachtwoord in";
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

                  _wachtwoordCheck("Minimaal 8 tekens", hasMinLength),
                  _wachtwoordCheck("Minstens 1 hoofdletter", hasUppercase),
                  _wachtwoordCheck("Minstens 1 kleine letter", hasLowercase),
                  _wachtwoordCheck("Minstens 1 cijfer", hasNumber),
                  _wachtwoordCheck("Minstens 1 speciaal teken", hasSpecialChar),

                  const SizedBox(height: 24),

                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: colors.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Registreren"),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Al een account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: const Text("Inloggen"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}