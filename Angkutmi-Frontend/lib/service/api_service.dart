import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
//inisalah jie bg bukan user ini
class TripService {
  // static const String baseUrl = "";
  final storage = FlutterSecureStorage();

  Future<Map<String, dynamic>> createTrip(Map<String, dynamic> tripData) async {
    final url = Uri.parse("http://127.0.0.1:8000/api/trip");
    final token = await storage.read(key: 'auth_token');

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(tripData),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print("Failed to create trip: ${response.body}");
        return {"success": false, "message": response.body};
      }
    } catch (e) {
      print("Error creating trip: $e");
      return {"success": false, "message": "Error creating trip"};
    }
  }

  Future<Map<String, dynamic>> updateLocation(int tripId, Map<String, dynamic> locationData) async {
    final url = Uri.parse("http://127.0.0.1:8000/api/trip/$tripId/location");
    final token = await storage.read(key: 'auth_token');

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(locationData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Failed to update location: ${response.body}");
        return {"success": false, "message": response.body};
      }
    } catch (e) {
      print("Error updating location: $e");
      return {"success": false, "message": "Error updating location"};
    }
  }

  Future<Map<String, dynamic>> acceptTrip(int tripId, Map<String, dynamic> driverData) async {
    final url = Uri.parse("http://127.0.0.1:8000/api/trip/$tripId/accept");
    final token = await storage.read(key: 'auth_token');

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(driverData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Failed to accept trip: ${response.body}");
        return {"success": false, "message": response.body};
      }
    } catch (e) {
      print("Error accepting trip: $e");
      return {"success": false, "message": "Error accepting trip"};
    }
  }

  Future<Map<String, dynamic>> startTrip(int tripId) async {
    final url = Uri.parse("http://127.0.0.1:8000/api/trip/$tripId/start");
    final token = await storage.read(key: 'auth_token');

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Failed to start trip: ${response.body}");
        return {"success": false, "message": response.body};
      }
    } catch (e) {
      print("Error starting trip: $e");
      return {"success": false, "message": "Error starting trip"};
    }
  }

  Future<Map<String, dynamic>> endTrip(int tripId) async {
    final url = Uri.parse("http://127.0.0.1:8000/api/trip/$tripId/end");
    final token = await storage.read(key: 'auth_token');

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Failed to end trip: ${response.body}");
        return {"success": false, "message": response.body};
      }
    } catch (e) {
      print("Error ending trip: $e");
      return {"success": false, "message": "Error ending trip"};
    }
  }
}
