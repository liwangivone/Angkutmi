import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '/modelsnantipi.dart'; // Import model PaketModel dan AlamatModel

class ApiLangganan {
  static const String apiUrl = "http://192.168.212.176:8000/api/subscriptions";
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  // Fungsi untuk membuat langganan baru
  Future<Map<String, dynamic>> createSubscription(
      PaketModel paket, AlamatModel alamat) async {
    final url = Uri.parse(apiUrl);

    try {
      // Ambil token autentikasi
      final token = await _getAuthToken();
      if (token == null) {
        return {'error': 'Token tidak ditemukan. Silakan login ulang.'};
      }

      final headers = _buildHeaders(token);

      // Siapkan JSON body
      final body = _buildRequestBody(paket, alamat);

      // Debugging: Cetak body yang dikirim
      print("Body yang dikirim ke API:");
      print(body);

      // Kirim POST request
      final response = await http.post(url, headers: headers, body: body);

      // Periksa status code dari respons
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Jika sukses, parse respons
        final responseBody = jsonDecode(response.body);
        print("Response success: ${response.body}");
        return {'message': responseBody['message']};
      } else {
        // Jika gagal, kembalikan error dari respons API
        print("Response error: ${response.statusCode} - ${response.body}");
        final errorResponse = jsonDecode(response.body);
        return {
          'error': errorResponse['message'] ?? 'Gagal membuat langganan'
        };
      }
    } catch (e) {
      // Tangkap error yang tidak terduga
      print("Exception: $e");
      return {'error': 'Terjadi kesalahan tidak terduga: $e'};
    }
  }

  // Helper untuk mengambil token autentikasi dari storage
  Future<String?> _getAuthToken() async {
    try {
      return await storage.read(key: 'auth_token');
    } catch (e) {
      print("Error saat mengambil token: $e");
      return null;
    }
  }

  // Helper untuk membangun headers HTTP
  Map<String, String> _buildHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Helper untuk membangun body JSON
  String _buildRequestBody(PaketModel paket, AlamatModel alamat) {
    return jsonEncode({
      'package_name': paket.name,
      'lat': alamat.lat,
      'lng': alamat.lng,
      'schedule_date': alamat.date,
      'schedule_time': alamat.time,
    });
  }
}
