import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'api_manager.dart';
import 'user_manager.dart';
import 'auth_page.dart';
import 'register_page.dart';
import 'admin.dart';
import 'user_film_list_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ApiManager apiManager = ApiManager(baseUrl: 'http://10.10.21.48:8000');

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserManager()),
        Provider.value(value: apiManager),
      ],
      child: MaterialApp(
        title: 'Flutter Auth CRUD Example',
        initialRoute: '/',
        routes: {
          '/': (context) => AuthPage(),
          '/register': (context) => RegisterPage(),
          '/userList': (context) => Dashboard(),
          '/film': (context) => User(),
        },
      ),
    );
  }
}
