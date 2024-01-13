import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

class UpdateSupporter extends StatefulWidget {
  String id_supporter;
  UpdateSupporter({
    super.key,
    required this.id_supporter
  });
 @override
  _UpdateSupporter createState() => _UpdateSupporter();
}

class _UpdateSupporter extends State<UpdateSupporter> {
  final TextEditingController _idSupporterController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _noTelpon = TextEditingController();
  DateTime? _tglDaftar;
  bool isLoading = false;
  File? _image;
  String? _imageFromServer = null;


  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      _idSupporterController.text = widget.id_supporter;
    });
    _getData();
  }

   void _getData() async {
      setState(() {
        isLoading = true;
      });
      const timeoutDuration = Duration(seconds: 3);
      final response = await http.get(
        Uri.parse(dotenv.env['API_BASE_URL']! + "/supporter?search=id_supporter&value=${widget.id_supporter}")
      ).timeout(timeoutDuration);

      
      final responseString = await response.body;
      final responseData = json.decode(responseString)['data'][0];
      setState(() {
        isLoading = false;
      });
      if(await response.statusCode == 200) {
        setState(() {
          _namaController.text = responseData['nama'];
          _alamatController.text = responseData['alamat'];
          _tglDaftar = DateTime.parse(responseData['tgl_daftar']);
          _noTelpon.text = responseData['no_telpon'];
          _imageFromServer = dotenv.env['IMAGE_BASE_URL']! + responseData['foto'];
        });
      }
  }

  void _removeImage() async {
    setState(() {
      _image = null;
    });
  }

  void _submitSupporter() async {
      if(_idSupporterController.text == "" || _namaController.text == "" || _noTelpon.text == "" || _tglDaftar == null || _alamatController.text == "") {
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
      const timeoutDuration = Duration(seconds: 3);
      // data['harga_klub'] = _hargaController.text;
      var request = http.MultipartRequest('POST', Uri.parse(dotenv.env['API_BASE_URL']! + "/supporter/${widget.id_supporter}"));
      if(_image != null) {
        request.files.add(
          http.MultipartFile(
            'foto',
            _image!.readAsBytes().asStream(),
            _image!.lengthSync(),
            filename: _image!.path
          )
        );
      }
      Map<String, String> headers = {
        'Content-Type': 'multipart/form-data'
      };

      request.headers.addAll(headers);
      request.fields.addAll({
        "id_supporter": _idSupporterController.text,
        "nama": _namaController.text,
        "no_telpon": _noTelpon.text,
        "tgl_daftar": "${_tglDaftar?.year}-${_tglDaftar?.month}-${_tglDaftar?.day}",
        "alamat": _alamatController.text,
        "_method": "PUT"
      });
      final response = await request.send();
      setState(() {
        isLoading = false;
      });
      final responseString = await response.stream.bytesToString();
      final responseData = json.decode(responseString);
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
              controller: _idSupporterController,
              decoration: const InputDecoration(
                labelText: 'ID Supporter',
              ),
              readOnly: true,
            ),
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(16.0),
            child: TextFormField(
              controller: _namaController,
              decoration: const InputDecoration(
                labelText: 'Nama Supporter',
              ),
            ),
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(16.0),
            child: TextFormField(
              controller: _alamatController,
              decoration: const InputDecoration(
                labelText: 'Alamat Supporter',
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 16, right: 16, bottom: 0, top: 0),
            child: 
              const Text("Tanggal Daftar", style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0, // Set your desired font size
              ))
            ,
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(16.0),
            child: ElevatedButton(
              child: Text(_tglDaftar == null ? "Pilih tanggal" : "${_tglDaftar?.year}-${_tglDaftar?.month}-${_tglDaftar?.day}"),
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                  context: context, 
                  initialDate: DateTime.now(), 
                  firstDate: DateTime(2000), 
                  lastDate: DateTime(9999)
                );
                if(picked != null && picked != _tglDaftar) {
                  setState(() {
                    _tglDaftar = picked;
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
            width: double.infinity,
            margin: EdgeInsets.all(16.0),
            child: TextFormField(
              controller: _noTelpon,
              decoration: const InputDecoration(
                labelText: 'No Telpon',
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 16, right: 16, bottom: 0, top: 0),
            child: 
              const Text("Foto", style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0, // Set your desired font size
              ))
            ,
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(16.0),
            child: _image == null ? ElevatedButton(
              child: Text("Pilih Foto"),
              onPressed: _pickImage, style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)
              )
            )
            ) : Column(
              children: [
              Image.file(_image!),
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(left: 0, right: 0, bottom: 10, top: 10),
                child: 
                ElevatedButton(onPressed: _removeImage, child: Text('Hapus Gambar'), style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)
              )
            ))
              )
            ]),
          ),
          _imageFromServer != null && _image == null ? Container(
              width: double.infinity,
              margin: EdgeInsets.all(16.0),
              child: Column(
              children: [
                Image.network(_imageFromServer!)
              ]
            )
          ) : const SizedBox(),
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(left: 10, right: 10, bottom: 20, top: 10),
            child: ElevatedButton(onPressed: _submitSupporter, child: Text("Submit"), style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)
              )
            ))
          )
        ])
    ) : Visibility(
      visible: isLoading,
      child: const SpinKitCircle(
        color: Colors.blue,
        size: 50.0,
      ),
    );
  }
}