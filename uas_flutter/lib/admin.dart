import 'dart:io';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'api_manager.dart';
import 'main.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DashboardForm(),
    );
  }
}

class DashboardForm extends StatefulWidget {
  const DashboardForm({Key? key}) : super(key: key);

  @override
  _DashboardFormState createState() => _DashboardFormState();
}

class _DashboardFormState extends State<DashboardForm> {
  File? _imageFile;
  File? _imageFiled;
  TextEditingController namaFilmController = TextEditingController();
  TextEditingController deskripsiFilmController = TextEditingController();
  TextEditingController genreFilmController = TextEditingController();
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      // Pindahkan logika untuk menampilkan dialog ke dalam setState
      _showAddDialog();
    }
  }

  final url = MyApp().apiManager.baseUrl;

  Future<void> _showAddDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tambah Data Film'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                      10), // Atur nilai sesuai keinginan untuk membuat sudut gambar menjadi rounded
                  child: _imageFile != null
                      ? Image.file(
                          _imageFile!,
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 100,
                          height: 100,
                          child: ElevatedButton(
                            onPressed: () => _pickImage(
                                ImageSource.gallery), // Mengganti ke galeri
                            child: Text(
                              "Upload Foto",
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                ),
                SizedBox(height: 15),
                TextField(
                  controller: namaFilmController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Nama Film',
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: deskripsiFilmController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Deskripsi Film',
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: genreFilmController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Genre',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Simpan'),
              onPressed: () async {
                try {
                  String namaFilm = namaFilmController.text;
                  String deskripsiFilm = deskripsiFilmController.text;
                  String genreFilm = genreFilmController.text;

                  print("Sebelum memanggil sendFilmData");
                  final apiManager =
                      Provider.of<ApiManager>(context, listen: false);

                  final send = await apiManager.sendFilmData(
                      namaFilm, deskripsiFilm, _imageFile!);
                  print("Setelah memanggil sendFilmData");

                  Navigator.pushReplacementNamed(context, '/userList');
                } catch (e) {
                  print("Error $e");
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final apiManager = Provider.of<ApiManager>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Film'),
        backgroundColor: Colors.blue, // Ganti dengan warna biru yang diinginkan
      ),
      body: Container(
        color: Colors.grey[200],
        child: FutureBuilder<Map<String, dynamic>>(
          future: apiManager.GetFilms(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              Navigator.pushReplacementNamed(context, '/login');
              return Center();
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text('No data available'),
              );
            } else {
              final jsonResponse = snapshot.data!;
              final data = jsonResponse['film'];

              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  if (index < data.length) {
                    final dataFilm = data[index];
                    return Card(
                      child: Column(
                        children: <Widget>[
                          Image.network(
                            '$url/film/${Uri.encodeFull(dataFilm['foto'])}',
                            height: 100.0,
                            fit: BoxFit.cover,
                          ),
                          Text('${dataFilm['judul']}'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              ElevatedButton(
                                child: Text('Edit',
                                    style: TextStyle(color: Colors.green)),
                                onPressed: () {
                                  TextEditingController namaFilmControllers =
                                      TextEditingController(
                                          text: dataFilm['judul']);
                                  TextEditingController
                                      deskripsiFilmControllers =
                                      TextEditingController(
                                          text: dataFilm['deskripsi']);
                                  TextEditingController genreFilmControllers =
                                      TextEditingController(
                                          text: dataFilm['genre']);

                                  Future<void> _pickImaged(
                                      ImageSource source) async {
                                    final pickedFiled = await ImagePicker()
                                        .pickImage(source: source);

                                    if (pickedFiled != null) {
                                      setState(() {
                                        _imageFiled = File(pickedFiled.path);
                                      });

                                      Navigator.of(context).pop();
                                    }
                                  }

                                  showDialog<void>(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Ubah Data Film'),
                                        content: SingleChildScrollView(
                                          child: ListBody(
                                            children: <Widget>[
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: _imageFiled != null
                                                    ? Image.file(
                                                        _imageFiled!,
                                                        height: 100,
                                                        width: 100,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : Container(
                                                        width: 100,
                                                        height: 100,
                                                        child: ElevatedButton(
                                                          onPressed: () =>
                                                              _pickImaged(
                                                                  ImageSource
                                                                      .gallery), // Mengganti ke galeri
                                                          child: Text(
                                                            "Ubah Foto",
                                                            style: TextStyle(
                                                                fontSize: 18),
                                                          ),
                                                        ),
                                                      ),
                                              ),
                                              SizedBox(height: 15),
                                              TextField(
                                                controller: namaFilmControllers,
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  labelText: 'Nama Film',
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              TextField(
                                                controller:
                                                    deskripsiFilmControllers,
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  labelText: 'Deskripsi Film',
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              TextField(
                                                controller:
                                                    genreFilmControllers,
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  labelText: 'genre film',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text('Batal'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: Text('Simpan'),
                                            onPressed: () async {
                                              try {
                                                String namaFilm =
                                                    namaFilmControllers.text;
                                                String deskripsiFilm =
                                                    deskripsiFilmControllers
                                                        .text;
                                                String genrepsiFilm =
                                                    genreFilmControllers.text;

                                                print(
                                                    "Sebelum memanggil sendFilmData");
                                                final apiManager =
                                                    Provider.of<ApiManager>(
                                                        context,
                                                        listen: false);

                                                final send = await apiManager
                                                    .UpdateFilmData(
                                                        namaFilm,
                                                        deskripsiFilm,
                                                        dataFilm['id']
                                                            .toString(),
                                                        _imageFiled!);
                                                print(
                                                    "Setelah memanggil sendFilmData");

                                                Navigator.pushReplacementNamed(
                                                    context, '/userList');
                                              } catch (e) {
                                                print("Error $e");
                                              }
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                              ElevatedButton(
                                child: Text('Hapus',
                                    style: TextStyle(color: Colors.red)),
                                onPressed: () async {
                                  try {
                                    final id = dataFilm['id'].toString();
                                    print("Sebelum memanggil sendFilmData");
                                    final apiManager = Provider.of<ApiManager>(
                                        context,
                                        listen: false);

                                    final send =
                                        await apiManager.DeleteFilmData(id);
                                    print("Setelah memanggil sendFilmData");

                                    Navigator.pushReplacementNamed(
                                        context, '/userList');
                                  } catch (e) {
                                    print("Error $e");
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }
}
