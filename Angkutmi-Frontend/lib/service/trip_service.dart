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

 Future<Map<String, dynamic>> getTripPrice(String tripid) async {
  final url = Uri.parse("http://127.0.0.1:8000/api/trip/$tripid");

  try {
    // Ambil token dari penyimpanan lokal
    final token = await storage.read(key: 'auth_token');
    if (token == null) {
      throw Exception('Token tidak ditemukan. Silakan login kembali.');
    }
    print('Token ditemukan: $token');

    // Kirim permintaan ke server
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    ).timeout(const Duration(seconds: 10), onTimeout: () {
      throw Exception('Permintaan ke server timeout.');
    });

    // Debug respons server
    print('Respons API: ${response.body}');

    // Periksa status respons
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      // Validasi data trip
      if (responseData == null || !responseData.containsKey('trip')) {
        throw Exception('Data trip tidak ditemukan dalam respons server.');
      }

      final tripData = responseData['trip'];

      // Validasi isi tripData
      if (tripData == null || tripData['id'] == null || tripData['price'] == null) {
        throw Exception('Data trip tidak lengkap. ID atau harga tidak ditemukan.');
      }

      // Ambil harga dan trip ID
      final tripId = tripData['id'];
      final price = tripData['price'];

      print('Trip ID: $tripId');
      print('Harga: $price');

      return {
        "success": true,
        "trip_id": tripId,
        "price": price,
      };
    } else {
      // Tangani error dari server
      final error = json.decode(response.body);
      return {
        "success": false,
        "message": error['message'] ?? 'Terjadi kesalahan pada server.',
      };
    }
  } catch (e) {
    // Tangani error lain
    return {
      "success": false,
      "message": 'Gagal terhubung ke server: $e',
    };
  }
}



}
