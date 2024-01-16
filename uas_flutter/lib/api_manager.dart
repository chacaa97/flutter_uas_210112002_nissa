import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_parser/http_parser.dart';

class ApiManager {
  final String baseUrl;
  final storage = FlutterSecureStorage();

  ApiManager({required this.baseUrl});

  //membuat fungsi memanggil api login.php
  Future<Map<String?, dynamic>?> authenticate(
      String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final token = jsonResponse['token'];
      // final role = jsonResponse['role'];

      // Save the token securely
      await storage.write(key: 'auth_token', value: token);

      return jsonResponse;
    } else {
      throw Exception(
          'Gagal Login: ${response.statusCode}} : ${response.body} ------');
    }
  }

  //membuat fungsi memanggil api register.php
  Future<void> register(String name, String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': username, 'password': password}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to register ${response.statusCode}');
    }
  }

  Future<void> UpdateFilmData(
      String judul, String deskripsi, String id, File imageFile) async {
    final token = await storage.read(key: 'auth_token');

    // Membuat request multipart/form-data
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/films'),
    )
      ..headers.addAll({
        'Authorization': 'Bearer $token',
      })
      ..fields.addAll({
        'id': id,
        'judul': judul,
        'deskripsi': deskripsi,
      });

    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      ));
    }

    // Melakukan request
    final response = await http.Response.fromStream(await request.send());

    if (response.statusCode != 201) {
      throw Exception('Failed to register ${response.statusCode}');
    }
  }

  Future<void> DeleteFilmData(String id) async {
    final token = await storage.read(key: 'auth_token');
    final response = await http.delete(
      Uri.parse('$baseUrl/api/delete'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({'id': id}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to register ${response.statusCode}');
    }
  }

  //membuat fungsi memanggil api list user atau crud.php
  Future<Map<String, dynamic>> GetFilms() async {
    final token = await storage.read(key: 'auth_token');

    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/dashboard'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse;
    } else {
      throw Exception('Failed to get users');
    }
  }

  Future<void> sendFilmData(
      String judul, String deskripsi, File imageFile) async {
    final token = await storage.read(key: 'auth_token');

    // Membuat request multipart/form-data
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/film'),
    )
      ..headers.addAll({
        'Authorization': 'Bearer $token',
      })
      ..fields.addAll({
        'judul': judul,
        'deskripsi': deskripsi,
      });

    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      ));
    }

    // Melakukan request
    final response = await http.Response.fromStream(await request.send());

    if (response.statusCode != 201) {
      throw Exception('Failed to register ${response.statusCode}');
    }
  }
}
