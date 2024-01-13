import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'update_supporter.dart';

class ListSupporter extends StatefulWidget {
 @override
  _ListSupporter createState() => _ListSupporter();
}

class _ListSupporter extends State<ListSupporter> {
  List<dynamic> items = [];
  String id_supporter = "";
  int totalPage = 0;
  int pageOffset = 1;
  int totalData = 0;
  bool isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getData();
  }

  // Fungsi buat munculin pop up konfirmasi
  void _showConfirmationDialog(BuildContext context, String id_supporter) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Hapus'),
          content: Text('Apakah anda ingin menghapus supporter: $id_supporter?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Perform the action when the user presses 'Cancel'
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                _deleteData(id_supporter);
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
  // Fungsi hapus data
  void _deleteData(String id) async {
    setState(() {
      isLoading = true;
    });
    const timeoutDuration = Duration(seconds: 3);
      final response = await http.delete(
        Uri.parse(dotenv.env['API_BASE_URL']! + "/supporter/${id}")
      ).timeout(timeoutDuration);

      
      final responseString = await response.body;
      final responseData = json.decode(responseString);
      setState(() {
        isLoading = false;
      });
      if(await response.statusCode == 200) {
          setState(() {
            if(pageOffset > 1) {
                pageOffset -= 1;
            }
            _getData();
          });
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

  // Ambil data dari DB
  void _getData() async {
      setState(() {
        isLoading = true;
      });
      const timeoutDuration = Duration(seconds: 3);
      final response = await http.get(
        Uri.parse(dotenv.env['API_BASE_URL']! + "/supporter?page_offset=${pageOffset}")
      ).timeout(timeoutDuration);

      
      final responseString = await response.body;
      final responseData = json.decode(responseString);
      setState(() {
        isLoading = false;
      });
      if(await response.statusCode == 200) {
        setState(() {
          items = responseData['data'];
          totalPage = responseData['total_page'];
          totalData = responseData['total_data'];
        });
      }
  }
  @override
  Widget build(BuildContext context) {
    // Rendering Update
    // Kalo dapat id_supporter nya munculin form update
    if(id_supporter != "") {
      return SingleChildScrollView(child:
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tombol kembali dari update
            Container(
              padding: EdgeInsets.only(left: 16, right: 16),
              child: ElevatedButton(
                child: Text("Kembali"),
                onPressed: () {
                  setState(() {
                    id_supporter = "";
                  });
                  _getData();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)
                  )
                )
              ),
            ),
            UpdateSupporter(id_supporter: id_supporter)
          ],
        )
      );
    }
    // Rendering Laporan
    return !isLoading ? SingleChildScrollView(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(left: 16, right: 16),
            child: 
            Row(
              mainAxisAlignment: pageOffset > 1 && pageOffset <= totalPage ? MainAxisAlignment.spaceBetween : MainAxisAlignment.end,
              children: [
                pageOffset > 1 && pageOffset <= totalPage ?
                Flexible(
                  flex: 1,
                  child: ElevatedButton(
                    child: Text("Sebelum"),
                    onPressed: () {
                      pageOffset -= 1;
                      _getData();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                      )
                    )
                  ),
                ) : SizedBox(),
                SizedBox(width: 16.0),
                pageOffset < totalPage ? Flexible(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle button tap
                      pageOffset += 1;
                      _getData();
                    },
                    child: Text('Berikut'), 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                      )
                    )
                  ),
                ) : SizedBox()
              ],
            ),
          ),
          Column(
              children: items.map<Container>((dynamic item) {
                return Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10),
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 2.0
                    ),
                    borderRadius: BorderRadius.circular(10.0)
                  ),
                  child:
                  Column(
                    children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(right: 5),
                                  child: 
                                    ElevatedButton(onPressed: () {
                                      setState(() {
                                        id_supporter = item['id_supporter'];
                                      });
                                    }, child: Text("Update"), style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)
                                      )
                                    )),
                                ),
                                Container(
                                  margin: EdgeInsets.only(right: 5),
                                  child: 
                                    ElevatedButton(onPressed: () {
                                      // Sebelum delete munculin popup
                                      _showConfirmationDialog(context, item['id_supporter']);
                                    }, child: Text("Delete"), style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)
                                      )
                                    )),
                                ),
                              ],
                            ),
                            Text("ID Supporter:", style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(item['id_supporter']),
                            Text("Nama Supporter:", style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(item['nama']),
                            Text("Alamat Supporter:", style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(item['alamat']),
                            Text("Tgl Daftar:", style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(item['tgl_daftar']),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
                              margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 0, bottom: 0),
                              child: Image.network(dotenv.env['IMAGE_BASE_URL']! + item['foto'])
                            )
                          ],
                        )
                    ],
                  )
                );
              }).toList(),
            ),
          Container(
            margin: EdgeInsets.only(left: 16, right: 16),
            child: 
            // Tombol pagination (Sebelumnya dan Berikutnya)
            Row(
              mainAxisAlignment: pageOffset > 1 && pageOffset <= totalPage ? MainAxisAlignment.spaceBetween : MainAxisAlignment.end,
              children: [
                pageOffset > 1 && pageOffset <= totalPage ?
                Flexible(
                  flex: 1,
                  child: ElevatedButton(
                    child: Text("Sebelum"),
                    onPressed: () {
                      pageOffset -= 1;
                      _getData();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                      )
                    )
                  ),
                ) : SizedBox(),
                SizedBox(width: 16.0),
                pageOffset < totalPage ? Flexible(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle button tap
                      pageOffset += 1;
                      _getData();
                    },
                    child: Text('Berikut'), 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                      )
                    )
                  ),
                ) : SizedBox()
              ],
            ),
          )
        ],
      )
    ) : 
    // Buat Munculin loading
    Visibility(
      visible: isLoading,
      child: SpinKitCircle(
        color: Colors.blue,
        size: 50.0,
      ),
    );
  }
}