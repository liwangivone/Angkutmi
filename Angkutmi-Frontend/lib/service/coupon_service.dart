import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CouponService {
  final FlutterSecureStorage storage = FlutterSecureStorage();

  CouponService();

  // Fetch active coupons from the backend
  Future<List<Map<String, dynamic>>> fetchCoupons() async {
    try {
      final token = await storage.read(key: 'auth_token');
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.get(
        Uri.parse('http://192.168.212.176:8000/api/coupons/'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['message'] == 'Coupons retrieved successfully.' && data['data'] != null) {
          List<Map<String, dynamic>> vouchers = List<Map<String, dynamic>>.from(
            data['data'].map((coupon) => {
              'product_name': coupon['product_name'] ?? 'Unknown',
              'picture_url': coupon['picture_url'] ?? null,
            }),
          );
          return vouchers;
        } else {
          throw Exception('Unexpected response format while fetching coupons');
        }
      } else {
        throw Exception('Failed to load coupons. Server returned: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching coupons: $e');
      throw Exception('Error fetching coupons: $e');
    }
  }

  // Fetch user's claimed coupons from the backend
Future<List<Map<String, dynamic>>> fetchClaimedCoupons() async {
  try {
    // Step 1: Retrieve the token
    final token = await storage.read(key: 'auth_token');
    if (token == null) {
      throw Exception('No token found in secure storage.');
    }

    // Step 2: Make the GET request to the server
    final response = await http.get(
      Uri.parse('http://192.168.212.176:8000/api/coupons/inventory'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    // Step 3: Handle different status codes and response formats
    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body);

        // Check if the response contains the expected data format
        if (data['message'] == 'Claimed coupons retrieved successfully.' && data['data'] != null) {
          List<Map<String, dynamic>> claimedCoupons = List<Map<String, dynamic>>.from(
            data['data'].map((coupon) => {
              'product_name': coupon['product_name'] ?? 'Unknown',
              'picture_url': coupon['picture_url'] ?? null,
            }),
          );
          return claimedCoupons;
        } else {
          // If the message is not as expected or data is missing, throw an exception
          throw Exception('Unexpected response format: ${data['message']}');
        }
      } catch (e) {
        // Catch JSON parsing errors
        throw FormatException('Error parsing JSON response: $e');
      }
    } else {
      // Handle server error based on the HTTP status code
      throw Exception('Failed to load claimed coupons. Server returned: ${response.statusCode}. Response body: ${response.body}');
    }
  } on FormatException catch (e) {
    // Handle JSON parsing errors separately
    print('Error parsing response body: $e');
    throw Exception('Invalid JSON format received from server.');
  } on http.ClientException catch (e) {
    // Handle network issues, timeouts, etc.
    print('Network error occurred: $e');
    throw Exception('Network error occurred while fetching claimed coupons. Please check your connection.');
  } catch (e) {
    // General catch-all for other errors
    print('An error occurred: $e');
    throw Exception('An unknown error occurred while fetching claimed coupons.');
  }
}


  // Redeem a coupon by its code
Future<void> redeemCoupon(String couponCode) async {
  try {
    // Fetch the stored token for authentication
    final token = await storage.read(key: 'auth_token');
    if (token == null) {
      throw Exception('No token found');
    }

    // Make the POST request to redeem the coupon
    final response = await http.post(
      Uri.parse('http://192.168.212.176:8000/api/coupons/$couponCode/redeem'), // Using couponCode in the URL
      headers: {
        'Content-Type': 'application/json',  // Ensure correct content type
        'Authorization': 'Bearer $token',    // Pass the token for authorization
      },
    );

    // Check if the response status is 200 OK
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['message'] == 'Coupon redeemed successfully.') {
        print('Coupon redeemed: ${data['message']}');
      } else {
        throw Exception('Failed to redeem coupon: ${data['message']}');
      }
    } else {
      // Handle cases where the server returns an error status code
      throw Exception('Failed to redeem coupon. Server returned: ${response.statusCode}');
    }
  } catch (e) {
    // Catch and log any exceptions during the process
    print('Error redeeming coupon: $e');
    throw Exception('Error redeeming coupon: $e');
  }
}

  // Fetch redeemed products for the user
  Future<List<Map<String, dynamic>>> fetchRedeemedProducts() async {
    try {
      final token = await storage.read(key: 'auth_token');
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.get(
        Uri.parse('http://192.168.212.176:8000/api/coupons/redeemed'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['message'] == 'Redeemed products retrieved successfully.' && data['data'] != null) {
          List<Map<String, dynamic>> redeemedProducts = List<Map<String, dynamic>>.from(
            data['data'].map((product) => {
              'product_name': product['product_name'],
              'picture_url': product['picture_url'] ?? null,
            }),
          );
          return redeemedProducts;
        } else {
          throw Exception('Unexpected response format while fetching redeemed products');
        }
      } else {
        throw Exception('Failed to load redeemed products. Server returned: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching redeemed products: $e');
      throw Exception('Error fetching redeemed products: $e');
    }
  }
}
