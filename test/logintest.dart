import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              key: Key('emailField'),
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              key: Key('passwordField'),
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {}, // Do nothing for now
              child: Text('Log In'),
            ),
          ],
        ),
      ),
    );
  }
}
