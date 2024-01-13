import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  // Fungsi buat check login
  checkLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Check apakah udah ada tokennya atau belum kalo ada langsung ganti screen ke home kalo nggak ada balikin ke login
    if(prefs.getString('token') != null) {
      Navigator.pushReplacementNamed(context, '/home');
    }
    else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue, // Set to match the splash color
      body: Center(
        child: FlutterLogo(size: 100.0),
      ),
    );
  }
}
