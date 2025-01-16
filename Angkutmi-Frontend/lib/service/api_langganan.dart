import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '/modelsnantipi.dart'; // Import model PaketModel and AlamatModel

class ApiLangganan {
  static const String apiUrl = "http://localhost:8000/api/subscriptions";
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> createSubscription(
      PaketModel paket, AlamatModel alamat) async {
    final url = Uri.parse(apiUrl);

    try {
      // Get the authentication token
      final token = await _getAuthToken();
      if (token == null) {
        return {'error': 'Token not found. Please log in again.'};
      }

      final headers = _buildHeaders(token);

      // Prepare the JSON body
      final body = _buildRequestBody(paket, alamat);

      // Debugging: Print the request body
      print("Request Body: $body");

      // Send POST request
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final responseBody = jsonDecode(response.body);
          print("Response Body: ${response.body}");

          if (responseBody.containsKey('message')) {
            return {
              'message': responseBody['message'],
              'subscription': responseBody['subscription'] ?? null,
            };
          } else {
            return {'error': 'Unexpected response format.'};
          }
        } catch (e) {
          print("Error parsing response JSON: $e");
          return {'error': 'Failed to parse response from server.'};
        }
      } else {
        print("Response Error: ${response.statusCode} - ${response.body}");
        // Safely handle error response and avoid issues with invalid JSON
        try {
          final errorResponse = jsonDecode(response.body);
          return {
            'error': errorResponse['message'] ?? 'Failed to create subscription',
          };
        } catch (e) {
          return {'error': 'Failed to parse error response.'};
        }
      }
    } catch (e) {
      print("Exception: $e");
      return {'error': 'An unexpected error occurred: $e'};
    }
  }

  Future<String?> _getAuthToken() async {
    try {
      return await storage.read(key: 'auth_token');
    } catch (e) {
      print("Error fetching token: $e");
      return null;
    }
  }

  Map<String, String> _buildHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  String _buildRequestBody(PaketModel paket, AlamatModel alamat) {
    // Ensure schedule_date is correctly formatted and included as a valid string
    String scheduleDate = alamat.date;  // Ensure this is in 'yyyy-MM-dd' format
    String scheduleTime = alamat.time;  // Ensure this is in 'HH:mm' format

    return jsonEncode({
      'package_name': paket.name,
      'lat': alamat.lat,  // Move lat out of address
      'lng': alamat.lng,  // Move lng out of address
      'schedule_date': scheduleDate,
      'schedule_time': scheduleTime,
    });
  }
}
