import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class TripService {
  final String apiUrl = "http://192.168.1.7:8080/api/trip";

  // Instance penyimpanan lokal
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> createTrip(Map<String, dynamic> tripData) async {
    // print("createTrip dipanggil ini tai sih cok kalau 2x");
    print("Creating trip with data: $tripData");
    
  final url = Uri.parse(apiUrl);

  try {
    final token = await storage.read(key: 'auth_token');
    if (token == null) {
      throw Exception('No token found. Silakan login kembali.');
    }

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
      body: json.encode(tripData),
    );

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      final trip = responseData['trip'];

      return {
        "success": true,
        "trip_id": trip?['trip_id'] ?? trip?['id'], // Periksa semua kemungkinan key
        "data": responseData,
      };
    } else {
      final error = json.decode(response.body);
      print("Error Response: $error");
      return {
        "success": false,
        "message": error['message'] ?? 'Terjadi kesalahan.',
      };
    }
  } catch (e) {
    print("Exception: $e");
    return {
      "success": false,
      "message": 'Gagal terhubung ke server: $e',
    };
  }
}


  Future<Map<String, dynamic>> getTripPrice(int tripid) async {
    final url = Uri.parse("http://192.168.1.7:8080/api/trip/$tripid");

    try {
      // Ambil token dari penyimpanan lokal
      final token = await storage.read(key: 'auth_token');
      if (token == null) {
        throw Exception('Token tidak ditemukan. Silakan login kembali.');
      }

      // Kirim permintaan ke server
      final response = await http
          .get(
            url,
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
          )
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Permintaan ke server timeout.');
      });

      // Debug respons server
      print('Respons API: ${response.body}');

      // Periksa status respons
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Validasi data trip
        if (responseData == null || !responseData.containsKey('price')) {
          throw Exception('Harga trip tidak ditemukan dalam respons server.');
        }

        // Ambil harga dan trip ID, konversi harga ke double
        final priceString = responseData['price'].toString();
        final price = double.parse(priceString); // Parse as double

        print('Harga: $price');

        return {
          "success": true,
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


  
  // void handleTripCreation(Map<String, dynamic> tripData) async {
  //   final tripResponse = await createTrip(tripData);

  //   if (tripResponse['success']) {
  //     final tripId = tripResponse['trip_id'];

  //     if (tripId == null) {
  //       print('Trip ID is null. Cannot fetch trip price.');
  //       return;
  //     }

  //     final priceResponse = await getTripPrice(tripId); // Ensure tripId is a String
  //     if (priceResponse['success']) {
  //       print('Trip Price: ${priceResponse['price']}');
  //     } else {
  //       print('Error fetching trip price: ${priceResponse['message']}');
  //     }
  //   } else {
  //     print('Error creating trip: ${tripResponse['message']}');
  //   }
  // }
}
