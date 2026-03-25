import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersonalisatiePage extends StatefulWidget {
  @override
  _PersonalisatiePageState createState() => _PersonalisatiePageState();
}

class _PersonalisatiePageState extends State<PersonalisatiePage> {
  Color backgroundColor = Colors.white;
  Color textColor = Colors.amber;

  @override
  void initState() {
    super.initState();
    loadColors();
  }

  // 🔹 Kleuren laden bij opstart
  Future<void> loadColors() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      backgroundColor = Color(prefs.getInt('bgColor') ?? Colors.white.value);
      textColor = Color(prefs.getInt('textColor') ?? Colors.amber.value);
    });
  }

  // 🔹 Kleuren opslaan
  Future<void> saveColors() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('bgColor', backgroundColor.value);
    await prefs.setInt('textColor', textColor.value);
  }

  void pickColor(BuildContext context, bool isBackground) {
    Color tempColor = isBackground ? backgroundColor : textColor;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Kies een kleur'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: tempColor,
              onColorChanged: (color) {
                tempColor = color;
              },
            ),
          ),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () async {
                setState(() {
                  if (isBackground) {
                    backgroundColor = tempColor;
                  } else {
                    textColor = tempColor;
                  }
                });

                await saveColors(); // 🔥 opslaan!

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Personalisatie',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),

            SizedBox(height: 30),

            ElevatedButton(
              onPressed: () => pickColor(context, true),
              child: Text('Kies achtergrondkleur'),
            ),

            SizedBox(height: 10),

            ElevatedButton(
              onPressed: () => pickColor(context, false),
              child: Text('Kies tekstkleur'),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
              onPressed: () => Navigator.pushNamed(context, '/home'),
              child: const Text("Home"),
            ),
          ],
        ),
      ),
    );
  }
}