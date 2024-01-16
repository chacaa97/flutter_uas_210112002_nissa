import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'api_manager.dart';
import 'user_manager.dart';

class AuthPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _authenticate(BuildContext context) async {
    final apiManager = Provider.of<ApiManager>(context, listen: false);
    final userManager = Provider.of<UserManager>(context, listen: false);

    final username = _usernameController.text;
    final password = _passwordController.text;

    try {
      final response = await apiManager.authenticate(username, password);
      final token = response?['token'];
      final role = response?['role'];

      userManager.setAuthToken(token);

      if (role == 1) {
        Navigator.pushReplacementNamed(context, '/userList');
      } else {
        Navigator.pushReplacementNamed(context, '/film');
      }
    } catch (e) {
      print('Authentication failed. Error: $e,');
      // Handle authentication failure
    }
  }

  @override
  Widget build(BuildContext context) {
    final message = ModalRoute.of(context)!.settings.arguments as String?;

    return Scaffold(
      appBar: AppBar(
        title: Text('Login Page',
            style:
                TextStyle(color: Colors.white)), // Change text color to white
        backgroundColor:
            Color.fromARGB(255, 253, 155, 9), // Change app bar color to blue
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (message != null)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.green,
                ),
                padding: EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    message,
                    style: TextStyle(
                      color: Colors.white,
                      // Atur warna sesuai kebutuhan
                    ),
                  ),
                ),
              ),
            SizedBox(height: 20),
            Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.lightBlue[100], // Change box color to light blue
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: InputBorder.none, // Remove the underline
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.lightBlue[100], // Change box color to light blue
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: InputBorder.none, // Remove the underline
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _authenticate(context),
              child: Text('Login'),
              // Change button style to match the theme
              style: ElevatedButton.styleFrom(
                primary: Colors.blue, // Change button color to blue
                onPrimary: Colors.white, // Change text color to white
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ), // Make the button rounded
                padding: EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 10,
                ), // Adjust the button size
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: Text('Register'),
              // Change button style to match the theme
              style: ElevatedButton.styleFrom(
                primary: Colors.blue, // Change button color to pink
                onPrimary: Colors.white, // Change text color to white
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ), // Make the button rounded
                padding: EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 10,
                ), // Adjust the button size
              ),
            ),
          ],
        ),
      ),
    );
  }
}
