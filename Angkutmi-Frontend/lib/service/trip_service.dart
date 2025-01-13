import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class TripService {
  final String apiUrl = "http://127.0.0.1:8000/api/trip";

   // Instance penyimpanan lokal
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> createTrip(Map<String, dynamic> tripData) async {
    final url = Uri.parse(apiUrl);

    try {
      // Ambil token dari penyimpanan
      final token = await storage.read(key: 'auth_token');
      if (token == null) {
        throw Exception('No token found. Silakan login kembali.');
      }

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode(tripData),
      );

      if (response.statusCode == 201) {
        return {
          "success": true,
          "data": json.decode(response.body),
        };
      } else {
        final error = json.decode(response.body);
        return {
          "success": false,
          "message": error['message'] ?? 'Terjadi kesalahan.',
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": 'Gagal terhubung ke server: $e',
      };
    }
  }

 // Fungsi untuk mendapatkan harga trip berdasarkan tripid
Future<Map<String, dynamic>> getTripPrice(String tripid) async {
    final url = Uri.parse("http://127.0.0.1:8000/api/trip/$tripid"); // Corrected URL
    
    try {
      final token = await storage.read(key: 'auth_token');
      if (token == null) {
        throw Exception('No token found. Silakan login kembali.');
      }

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        return {
          "success": true,
          "price": responseData['trip']['price'], // Extract price from the trip data
        };
      } else {
        final error = json.decode(response.body);
        return {
          "success": false,
          "message": error['message'] ?? 'Terjadi kesalahan.',
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": 'Gagal terhubung ke server: $e',
      };
    }
}

}
