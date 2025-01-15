import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '/modelsnantipi.dart';

class ApiLangganan {
  static const String apiUrl = "http://127.0.0.1:8000/api/subscriptions";
  final FlutterSecureStorage storage = const FlutterSecureStorage();

Future<Map<String, dynamic>> createSubscription(
    PaketModel paket, AlamatModel alamat) async {
  final url = Uri.parse("http://127.0.0.1:8000/api/subscriptions");

  try {
    // Ambil token dari storage
    final token = await storage.read(key: 'auth_token');
    if (token == null) {
      throw Exception('No token found. Silakan login kembali.');
    }

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // Perbaiki body JSON
    final body = jsonEncode({
      'package_name': paket.name, // Nama paket
      'price': paket.price, // Harga paket
      'address': {
        'lat': alamat.lat, // Latitude
        'lng': alamat.lng, // Longitude
      },
      'schedule_date': alamat.date, // Format tanggal harus benar
    });
    // Tambahkan debug print di sini
    print("Body yang dikirim ke API:");
    print(body);

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Response success: ${response.body}");
      return jsonDecode(response.body);
    } else {
      print("Response error: ${response.statusCode} - ${response.body}");
      return {'error': 'Failed to create subscription: ${response.body}'};
    }
  } catch (e) {
    print("Exception: $e");
    return {'error': 'An unexpected error occurred: $e'};
  }
}
}
