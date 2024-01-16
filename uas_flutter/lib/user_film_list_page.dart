import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'api_manager.dart';
import 'main.dart';

class User extends StatelessWidget {
  const User({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: UserForm(),
    );
  }
}

class UserForm extends StatefulWidget {
  const UserForm({Key? key}) : super(key: key);

  @override
  _UserFormState createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final url = MyApp().apiManager.baseUrl;

  @override
  Widget build(BuildContext context) {
    final apiManager = Provider.of<ApiManager>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Rekomendasi Film'),
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
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200.0,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                ),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  if (index < data.length) {
                    final dataFilm = data[index];
                    return Container(
                      margin: EdgeInsets.all(5.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5.0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Image.network(
                                '$url/film/${Uri.encodeFull(dataFilm['foto'])}',
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    '${dataFilm['judul']}',
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 5.0),
                                  Text(
                                    '${dataFilm['deskripsi']}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 5.0),
                                  Text(
                                    '${dataFilm['genre']}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
    );
  }
}
