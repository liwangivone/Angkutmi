import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class PaymentService {
  final String apiUrl = "http://192.168.212.176/api/payments"; // Sesuaikan dengan URL API Anda
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  // Method untuk membuat pembayaran
  Future<Map<String, dynamic>> createPayment({
    required int tripId,
    required double price,
    required String paymentMethod, // Metode pembayaran yang dipilih
  }) async {
    final url = Uri.parse(apiUrl);

    try {
      // Ambil token dari penyimpanan
      final token = await storage.read(key: 'auth_token');
      if (token == null) {
        throw Exception('Token tidak ditemukan. Silakan login kembali.');
      }

      // Kirim request ke server
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          'trip_id': tripId,
          'payment_type': paymentMethod, // Kirim metode pembayaran
        }),
      );

      // Cek status kode dari respons
      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData['data'], // Mengambil data pembayaran dari response
          'trip_id': responseData['trip_id'], // Mengambil trip_id
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Gagal membuat pembayaran.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal terhubung ke server: $e',
      };
    }
  }

  // Method untuk mendapatkan detail pembayaran
  Future<Map<String, dynamic>> getPaymentDetails(int paymentId) async {
    final url = Uri.parse("$apiUrl/$paymentId");

    try {
      // Ambil token dari penyimpanan
      final token = await storage.read(key: 'auth_token');
      if (token == null) {
        throw Exception('Token tidak ditemukan. Silakan login kembali.');
      }

      // Kirim request ke server
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      // Cek status kode dari respons
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData['payment'], // Mengambil data pembayaran
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Gagal mengambil detail pembayaran.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal terhubung ke server: $e',
      };
    }
  }
}
