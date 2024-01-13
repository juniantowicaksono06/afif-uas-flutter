// login_page.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // State Value untuk username dan password
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;

  // Fungsi untuk handle login
  Future _handleLogin() async {
    const timeoutDuration = Duration(seconds: 3);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = _usernameController.text;
    String password = _passwordController.text;
    setState(() {
      isLoading = true;
    });
    try {
      var data = new Map<String, dynamic>();
      data['username'] = username;
      data['password'] = password;
      final response = await http.post(
        Uri.parse(dotenv.env['API_BASE_URL']! + "/login"),
        body: data
      ).timeout(timeoutDuration);
      final responseString = await response.body;
      final responseData = json.decode(responseString);
      setState(() {
        isLoading = false;
      });
      if(await response.statusCode == 200) {
        prefs.setString("token", responseData['token']);
        Navigator.pushReplacementNamed(context, '/home');
      }
      else {
        print("login failed");
      }
    } catch (e) {
      print(e);
      print("Error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return !isLoading ? Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.all(16.0),
                child: TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                  ),
                ),
              ),
            ),
            Center(
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.all(16.0),
                child: TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                  ),
                ),
              ),
            ),
            Center(
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _handleLogin,
                  child: const Text('Login'), 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                    )
                  )
                ),
              ),
            )
          ],
        ),
      ),
    ) : 
    Visibility(
      visible: isLoading,
      child: SpinKitCircle(
        color: Colors.blue,
        size: 50.0,
      ),
    );
  }
}
