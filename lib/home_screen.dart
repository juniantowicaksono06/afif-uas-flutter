import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'create_supporter.dart';
import 'create_klub.dart';
import 'list_supporter.dart';
import 'list_klub.dart';

class HomeScreen extends StatefulWidget {
 @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _headerTitle = "Klub Sepakbola";
  static final List<StatefulWidget> _widgetOptions = <StatefulWidget> [
    CreateKlub(),
    CreateSupporter(),
    ListKlub(),
    ListSupporter(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if(index == 0) {
        _headerTitle = "Klub Sepakbola";
      }
      else if(index == 1) {
        _headerTitle = "Supporter";
      }
      else if(index == 2) {
        _headerTitle = "Laporan Klub Sepakbola";
      }
      else if(index == 3) {
        _headerTitle = "Laporan Supporter";
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_headerTitle)),
      body: Container(
        child: _widgetOptions[_selectedIndex]
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration:  BoxDecoration(
                color: Colors.blue
              ),
              child: Text('Tugas UAS', style: TextStyle(color: Colors.white),),
            ),
            ListTile(
              title: const Text("Klub Sepakbola"),
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Supporter"),
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Laporan Klub Sepakbola"),
              onTap: () {
                // Navigator.pop(context);
                _onItemTapped(2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Laporan Supporter"),
              onTap: () {
                // Navigator.pop(context);
                _onItemTapped(3);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Logout"),
              onTap: () async {
                final SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.remove('token');
                Navigator.pop(context);
                Navigator.popAndPushNamed(context, '/login');
              },
            )
          ],
        )
      ),
    );
  }
}