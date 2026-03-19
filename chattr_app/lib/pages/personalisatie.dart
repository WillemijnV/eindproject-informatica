import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class PersonalisatiePage extends StatefulWidget {
  @override
  _PersonalisatiePageState createState() => _PersonalisatiePageState();
}

class _PersonalisatiePageState extends State<PersonalisatiePage> {
  Color backgroundColor = Colors.white;
  Color textColor = Colors.amber;

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
              onPressed: () {
                setState(() {
                  if (isBackground) {
                    backgroundColor = tempColor;
                  } else {
                    textColor = tempColor;
                  }
                });
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

            // Knop voor achtergrondkleur
            ElevatedButton(
              onPressed: () => pickColor(context, true),
              child: Text('Kies achtergrondkleur'),
            ),

            SizedBox(height: 10),

            // Knop voor tekstkleur
            ElevatedButton(
              onPressed: () => pickColor(context, false),
              child: Text('Kies tekstkleur'),
            ),
          ],
        ),
      ),
    );
  }
}