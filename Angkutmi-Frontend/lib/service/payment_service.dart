// import 'dart:convert';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:http/http.dart' as http;

// class PaymentService {
//   final String apiUrl = "http://127.0.0.1:8000/api/payments";

//   // Instance penyimpanan lokal
//   final FlutterSecureStorage storage = const FlutterSecureStorage();

//   // Method untuk membuat payment
//   Future<Map<String, dynamic>> createPayment({
//     required int tripId,
//     required String paymentType,
//   }) async {
//     final url = Uri.parse(apiUrl);

//     try {
//       // Ambil token dari penyimpanan
//       final token = await storage.read(key: 'auth_token');
//       if (token == null) {
//         throw Exception('Token tidak ditemukan. Silakan login kembali.');
//       }

//       // Kirim request ke server
//       final response = await http.post(
//         url,
//         headers: {
//           "Content-Type": "application/json",
//           "Authorization": "Bearer $token",
//         },
//         body: jsonEncode({
//           'trip_id': tripId,
//           'payment_type': paymentType,
//         }),
//       );

//       // Cek status kode dari respons
//       if (response.statusCode == 201) {
//         final responseData = jsonDecode(response.body);
//         return {
//           'success': true,
//           'data': responseData,
//         };
//       } else {
//         final error = jsonDecode(response.body);
//         return {
//           'success': false,
//           'message': error['message'] ?? 'Gagal membuat pembayaran.',
//         };
//       }
//     } catch (e) {
//       return {
//         'success': false,
//         'message': 'Gagal terhubung ke server: $e',
//       };
//     }
//   }

//   // Method untuk mendapatkan detail pembayaran
//   Future<Map<String, dynamic>> getPaymentDetails(int paymentId) async {
//     final url = Uri.parse("$apiUrl/$paymentId");

//     try {
//       // Ambil token dari penyimpanan
//       final token = await storage.read(key: 'auth_token');
//       if (token == null) {
//         throw Exception('Token tidak ditemukan. Silakan login kembali.');
//       }

//       // Kirim request ke server
//       final response = await http.get(
//         url,
//         headers: {
//           "Content-Type": "application/json",
//           "Authorization": "Bearer $token",
//         },
//       );

//       // Cek status kode dari respons
//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         return {
//           'success': true,
//           'data': responseData,
//         };
//       } else {
//         final error = jsonDecode(response.body);
//         return {
//           'success': false,
//           'message': error['message'] ?? 'Gagal mengambil detail pembayaran.',
//         };
//       }
//     } catch (e) {
//       return {
//         'success': false,
//         'message': 'Gagal terhubung ke server: $e',
//       };
//     }
//   }
// }
