import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kejaksaan/model/model_jaksa.dart';
import 'package:kejaksaan/model/model_status.dart';
import 'package:kejaksaan/screen_page/admin/pengaduan/jms/page_listjaksa.dart';
import 'package:kejaksaan/utils/ip.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class DetailJaksaAdmin extends StatelessWidget {
  final Datum Jaksa;

  DetailJaksaAdmin({required this.Jaksa});

  Future<String> _downloadFile(String url) async {
    final http.Response response = await http.get(Uri.parse(url));
    final Directory tempDir = await getTemporaryDirectory();
    final String tempPath = tempDir.path;
    final String fileName = url.split('/').last;
    final File file = File('$tempPath/$fileName');
    await file.writeAsBytes(response.bodyBytes);
    return file.path;
  }

  Future<void> approvePengaduan(
      BuildContext context, String idp, String status) async {
    try {
      http.Response res = await http.post(
          Uri.parse('${url}/db_kejaksaan/updateJaksaAdmin.php'),
          body: {"status": status, "id": idp});

      // Periksa apakah permintaan berhasil (status kode 200)
      if (res.statusCode == 200) {
        // Parsing respon dari JSON ke objek ModelDeleteMahasiswa
        ModelUpdateStatus data = modelUpdateStatusFromJson(res.body);

        if (data.isSuccess == true) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => PageListJaksaAdmin()),
              (route) => false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${data.message}')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${data.message}')),
          );
          print(data.message);
        }
      } else {
        // Menampilkan pesan kesalahan jika permintaan tidak berhasil
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengubah Data')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      print(e);
    }
  }

  String getStatusText(int status) {
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'Approved';
      case 2:
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.asset(
                  'gambar/bg2.jpeg',
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PageListJaksaAdmin(),
                          ),
                          (route) => false,
                        );
                      },
                      icon: Icon(Icons.arrow_back)),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    'gambar/kejaksaan.png',
                    scale: 10,
                  ),
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Detail Pengaduan Jaksa Masuk Sekolah',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Nama',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(': '),
                      Expanded(
                        flex: 4,
                        child: Text('${Jaksa.nama ?? ''}',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Sekolah Yang Di Tuju',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(': '),
                      Expanded(
                        flex: 4,
                        child: Text('${Jaksa.sekolah ?? ''}',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Status',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(': '),
                      Expanded(
                        flex: 4,
                        child: Text('${getStatusText(Jaksa.status ?? 0)}',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll<Color>(
                                  Colors.redAccent),
                            ),
                            onPressed: () {
                              approvePengaduan(context, Jaksa.id.toString(), "2");
                            },
                            child: Text(
                              "Reject",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                            )),
                        ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll<Color>(
                                  Colors.greenAccent),
                            ),
                            onPressed: () {
                              approvePengaduan(context, Jaksa.id.toString(), "1");
                            },
                            child: Text(
                              "Approve",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                            )),
                      ],
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
