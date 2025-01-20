import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class PaymentService {
  final String apiUrl = "http://192.168.166.176:8000/api/payments";
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> createPayment({
    required int tripId,
    required double price,
    required String paymentMethod,
  }) async {
    try {
      // Debug print
      print('Creating payment with data:');
      print('Trip ID: $tripId');
      print('Price: $price');
      print('Payment Method: $paymentMethod');

      final token = await storage.read(key: 'auth_token');
      if (token == null) {
        throw Exception('Token tidak ditemukan. Silakan login kembali.');
      }

      print('Token found: ${token.substring(0, 10)}...'); // Print sebagian token untuk debug

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json", // Tambahkan ini
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          'trip_id': tripId,
          'payment_type': paymentMethod,
          'price': price,
          'amount': price, // Tambahkan ini jika backend membutuhkan
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Connection timeout'),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      switch (response.statusCode) {
        case 201:
          final responseData = jsonDecode(response.body);
          return {
            'success': true,
            'data': responseData['data'],
            'trip_id': responseData['trip_id'],
          };
        case 401:
          throw Exception('Unauthorized: Token tidak valid atau kadaluarsa');
        case 400:
          final error = jsonDecode(response.body);
          throw Exception(error['message'] ?? 'Bad Request');
        case 404:
          throw Exception('Trip tidak ditemukan');
        case 500:
          throw Exception('Internal Server Error');
        default:
          throw Exception('HTTP Error: ${response.statusCode}');
      }
    } on FormatException catch (e) {
      print('Format Exception: $e');
      return {
        'success': false,
        'message': 'Response format tidak valid. Pastikan API mengembalikan JSON',
      };
    } on Exception catch (e) {
      print('Error Exception: $e');
      return {
        'success': false,
        'message': e.toString(),
      };
    } catch (e) {
      print('Unknown Error: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan tidak terduga: $e',
      };
    }
  }


  // Method untuk mendapatkan detail pembayaran
  Future<Map<String, dynamic>> getPaymentDetails(int paymentId) async {
    final url = Uri.parse("http://192.168.166.176/api/payments/$paymentId");

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
