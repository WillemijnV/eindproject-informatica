import 'package:flutter/material.dart';

Form(
    key: _formKey,
    child: Column(
        children: [
            TextFormField(
                decoration: InputDecoration(labelText: 'Vul uw naam in'),
                validator: (value) {
                    if (value == null || value.isEmpty) {
                        return 'Vul alstublieft uw naam in';
                    }
                    return null;
                },
            ),
            ElevatedButton(
                onPressed: () {
                    if (_formKey.currentState!.validate()) {
                        // Process data
                    }
                },
                child: Text('Indienen'),
            ),
        ],
    ),
)