import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PaymentService {
  final String baseUrl = "http://127.0.0.1:8000/api/";
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  // Retrieve token
  Future<String?> getToken() async {
    try {
      final token = await storage.read(key: 'auth_token');
      if (token == null) {
        throw Exception('No token found');
      }
      return token;
    } catch (e) {
      print("Error retrieving token: $e");
      throw Exception("Error retrieving token: $e");
    }
  }

  // Create a payment
  Future<Map<String, dynamic>> createPayment(int tripId, String paymentType) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse("${baseUrl}payments"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'trip_id': tripId,
          'payment_type': paymentType,
        }),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to create payment: ${response.body}");
      }
    } catch (e) {
      print("Error creating payment: $e");
      throw Exception("Error creating payment: $e");
    }
  }

  // Get payment details
  Future<Map<String, dynamic>> getPaymentDetails(int paymentId) async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse("${baseUrl}payments/$paymentId"),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to fetch payment details: ${response.body}");
      }
    } catch (e) {
      print("Error fetching payment details: $e");
      throw Exception("Error fetching payment details: $e");
    }
  }
}
