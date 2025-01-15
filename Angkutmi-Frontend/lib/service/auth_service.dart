// auth_service.dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:angkutmi/home.dart';

// Initialize the storage for secure token storage
final storage = FlutterSecureStorage();

// API endpoint URL
const String apiUrl = 'http://192.168.212.176:8000/api/login';

class AuthService {
  // Login function
  Future<bool> login(String phone, String password, BuildContext context) async {
    final url = Uri.parse(apiUrl);
    print("Login attempt with phone: $phone");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone_number': phone,
          'password': password,
        }),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final token = responseData['token'];
        final userName = responseData['user']['name'];

        if (token != null) {
          // Save token securely
          await storage.write(key: 'auth_token', value: token);
          await storage.write(key: 'user_name', value: userName);
          print("Token saved successfully: $token");

          // Redirect to HomeScreen on successful login
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen(userName: userName)),
          );
          return true;
        } else {
          print("No token found in the response");
        }
      } else {
        print("Failed to log in, status code: ${response.statusCode}");
      }

      // Handle error if login fails
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed')),
      );
    } catch (e) {
      // Handle error during API request
      print("Error occurred during login: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred, please try again')),
      );
    }
    return false;
  }

  // Register function
  Future<Map<String, dynamic>> register(
      String name, String phone, String password) async {
    final url = Uri.parse('http://192.168.212.176:8000/api/register');

    try {
      print("Attempting to register with name: $name, phone: $phone");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'phone_number': phone,
          'password': password,
        }),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      // Handle response and return data
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("Registration response: $responseData");

        return {
          'success': responseData['success'],
          'message': responseData['message'] ?? '',
        };
      } else {
        print("Failed to register, status code: ${response.statusCode}");
        return {'success': false, 'message': 'Terjadi kesalahan pada server'};
      }
    } catch (e) {
      print("Error occurred during registration: $e");
      return {'success': false, 'message': 'Terjadi kesalahan. Periksa koneksi Anda.'};
    }
  }
}
