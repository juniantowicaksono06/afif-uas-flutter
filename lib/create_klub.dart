import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateKlub extends StatefulWidget {
 @override
  _CreateKlub createState() => _CreateKlub();
}

class _CreateKlub extends State<CreateKlub> {
  final TextEditingController _idKlubController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _kotaController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  bool isLoading = false;
  List<String> options = ['1-3', '4-6', '7-15', '16-18'];
  String _peringkat = '1-3';
  int _kondisiKlub = 1;
  DateTime? _tglBerdiri = null;

  void _handleKondisiKlubChanged(int? value) {
    if(value == null) 
    {
      return;
    }
    setState(() {
      _kondisiKlub = value;
    });
  }

  void _handlePeringkatChanged(newValue) {
    setState(() {
      _peringkat = newValue;
    });
  }
  // Fungsi untuk submit data ke server / API
  void _submitKlub() async {
      const timeoutDuration = Duration(seconds: 3);
      var data = new Map<String, dynamic>();
      data['id_klub'] = _idKlubController.text;
      data['nama_klub'] = _namaController.text;
      data['tgl_berdiri'] = "${_tglBerdiri?.year}-${_tglBerdiri?.month}-${_tglBerdiri?.day}";
      data['kondisi_klub'] = _kondisiKlub.toString();
      data['kota_klub'] = _kotaController.text;
      data['peringkat'] = _peringkat;
      data['harga_klub'] = _hargaController.text;
      if(data['id_klub'] == "" || data['nama_klub'] == "" || data['tgl_berdiri'] == "" || data['kondisi_klub'] == "" || data['kota_klub'] == "" || data['peringkat'] == "" || data['harga_klub'] == "") {
        Fluttertoast.showToast(
          msg: "Silahkan lengkapi semua data terlebih dahulu",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return;
      }
      setState(() {
        isLoading = true;
      });
      final response = await http.post(
        Uri.parse(dotenv.env['API_BASE_URL']! + "/klub-sepakbola"),
        body: data
      ).timeout(timeoutDuration);
      final responseString = await response.body;
      final responseData = json.decode(responseString);
      print(responseData);
      setState(() {
        isLoading = false;
      });
      if(await response.statusCode == 201) {
        // Navigator.pushReplacementNamed(context, '/home');
        Fluttertoast.showToast(
          msg: responseData['message'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0,
        );

      }
      else {        
        Fluttertoast.showToast(
          msg: responseData['message'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
  }

  @override
  Widget build(BuildContext context) {
    return !isLoading ? SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(16.0),
            child: TextFormField(
              controller: _idKlubController,
              decoration: const InputDecoration(
                labelText: 'ID Klub',
              ),
            ),
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(16.0),
            child: TextFormField(
              controller: _namaController,
              decoration: const InputDecoration(
                labelText: 'Nama Klub',
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 16, right: 16, bottom: 0, top: 0),
            child: 
              Text("Tanggal Berdiri", style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0, // Set your desired font size
              ))
            ,
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(16.0),
            child: ElevatedButton(
              child: Text(_tglBerdiri == null ? "Pilih tanggal" : "${_tglBerdiri?.year}-${_tglBerdiri?.month}-${_tglBerdiri?.day}"),
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                  context: context, 
                  initialDate: DateTime.now(), 
                  firstDate: DateTime(2000), 
                  lastDate: DateTime(9999)
                );
                if(picked != null && picked != _tglBerdiri) {
                  setState(() {
                    _tglBerdiri = picked;
                  });
                }
              }, style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)
              )
            )
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 16, right: 16, bottom: 0, top: 0),
            child: 
              Text("Kondisi Klub", style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0, // Set your desired font size
              ))
            ,
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(1.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Radio(value: 1, groupValue: _kondisiKlub, onChanged: _handleKondisiKlubChanged),
                    Text('Baik')
                  ],
                ),
                Row(
                  children: [
                    Radio(value: 2, groupValue: _kondisiKlub, onChanged: _handleKondisiKlubChanged),
                    Text('Tidak Baik')
                  ],
                ),
                Row(
                  children: [
                    Radio(value: 3, groupValue: _kondisiKlub, onChanged: _handleKondisiKlubChanged),
                    Text('Bangkrut')
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(16.0),
            child: TextFormField(
              controller: _kotaController,
              decoration: const InputDecoration(
                labelText: 'Kota Klub',
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 16, right: 16, bottom: 0, top: 0),
            child: 
              Text("Peringkat Klub", style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0, // Set your desired font size
              )),
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(left: 16.0, right: 16.0),
            child: DropdownButton<String>(
              isExpanded: true,
              value: _peringkat,
              onChanged: _handlePeringkatChanged,
              items: options.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              },).toList()
            ),
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(left: 16.0, right: 16.0),
            child: TextFormField(
              controller: _hargaController,
              decoration: const InputDecoration(
                labelText: 'Harga Klub',
              ),
            ),
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(16.0),
            child: ElevatedButton(
              child: Text("Submit"),
              onPressed: _submitKlub, style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)
              )
            )
              // onPressed: () {
              //   setState(() {
              //     isLoading = true;
              //   });
              // },
            ),
          )
        ],
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