import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../url.dart';

class GachaService {
  // final String baseUrl = "http://192.168.251.1:8080"; // Base URL variable
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

  // Fetch current progress
  Future<Map<String, dynamic>> fetchProgress() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse("$baseUrl/api/wheel/progress"), // Updated URL
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print({
          'progress': responseData['progress'],
          'trips_completed': responseData['trip_count'], // Ensure 'trip_count' is included in the API response
        });
        return {
          'progress': responseData['progress'],
          'trips_completed': responseData['trip_count'], // Ensure 'trip_count' is included in the API response
        };
      } else {
        throw Exception("Failed to fetch progress: ${response.body}");
      }
    } catch (e) {
      print("Error fetching progress: $e");
      throw Exception("Error fetching progress: $e");
    }
  }

  // Fetch wheel slices
  Future<List<Map<String, dynamic>>> fetchWheelSlices() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse("$baseUrl/api/wheel/slices"), // Updated URL
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Ensure the response data is properly decoded into a List of Maps
        final responseData = json.decode(response.body);
        
        // Check if the 'data' field is present and is a List
        if (responseData['data'] is List) {
          return List<Map<String, dynamic>>.from(responseData['data']);
        } else {
          throw Exception('Unexpected response format: data is not a List');
        }
      } else {
        throw Exception("Failed to fetch wheel slices: ${response.body}");
      }
    } catch (e) {
      print("Error fetching wheel slices: $e");
      throw Exception("Error fetching wheel slices: $e");
    }
  }

  // Spin the wheel
  Future<Map<String, dynamic>> spinWheel() async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse("$baseUrl/api/wheel/spin"), // Updated URL
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to spin the wheel: ${response.body}");
      }
    } catch (e) {
      print("Error spinning the wheel: $e");
      throw Exception("Error spinning the wheel: $e");
    }
  }

  // Claim a reward
  Future<Map<String, dynamic>> claimReward() async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse("$baseUrl/api/reward/claim"), // Updated URL
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to claim the reward: ${response.body}");
      }
    } catch (e) {
      print("Error claiming the reward: $e");
      throw Exception("Error claiming the reward: $e");
    }
  }
}
