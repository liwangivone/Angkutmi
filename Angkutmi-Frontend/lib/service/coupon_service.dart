import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CouponService {
  final String baseUrl;
  final FlutterSecureStorage storage = FlutterSecureStorage();

  CouponService({required this.baseUrl});

  // Fetch active coupons from the backend
  Future<List<String>> fetchCoupons() async {
    try {
      final token = await storage.read(key: 'auth_token');
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/coupons/'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        print('Response Data: $data'); // Print the entire response data

        if (data['message'] == 'Coupons retrieved successfully.' && data['data'] != null) {
          List<String> vouchers = List<String>.from(
              data['data'].map((coupon) => coupon['product_name'] ?? 'Unknown'));
          print('Coupons: $vouchers'); // Print the list of coupons
          return vouchers;
        } else {
          throw Exception('Failed to load coupons: Unexpected response format');
        }
      } else {
        print('Error: Server returned status code ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load coupons: Server returned ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
      rethrow; // Re-throw the exception for further handling
    }
  }

  // Fetch user's claimed coupons from the backend
Future<List<String>> fetchClaimedCoupons() async {
  try {
    final token = await storage.read(key: 'auth_token');
    if (token == null) {
      throw Exception('No token found');
    }

    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/coupons/inventory'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      print('Response Data: $data'); // Print the entire response data

      if (data['message'] == 'Claimed coupons retrieved successfully.' && data['data'] != null) {
        List<String> claimedCoupons = List<String>.from(
          data['data'].map((coupon) => coupon['product_name'] ?? 'Unknown'),
        );
        print('Claimed Coupons: $claimedCoupons'); // Print the list of claimed coupons
        return claimedCoupons;
      } else {
        throw Exception('Failed to load claimed coupons: Unexpected response format');
      }
    } else {
      print('Error: Server returned status code ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to load claimed coupons: Server returned ${response.statusCode}');
    }
  } catch (e) {
    print('Error occurred: $e');
    rethrow; // Re-throw the exception for further handling
  }
}

  // Redeem a coupon by its code
  Future<void> redeemCoupon(String couponCode) async {
    try {
      final token = await storage.read(key: 'auth_token');
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/coupons/$couponCode/redeem'),
        body: json.encode({'code': couponCode}),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Coupon redeemed: ${data['message']}');
      } else {
        throw Exception('Failed to redeem coupon');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Fetch redeemed products for the user
  Future<List<String>> fetchRedeemedProducts() async {
    try {
      final token = await storage.read(key: 'auth_token');
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/coupons/redeemed'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['message'] == 'Redeemed products retrieved successfully.') {
          List<String> redeemedProducts = List<String>.from(
              data['data'].map((product) => product['product_name']));
          return redeemedProducts;
        } else {
          throw Exception('Failed to load redeemed products');
        }
      } else {
        throw Exception('Failed to load redeemed products');
      }
    } catch (e) {
      rethrow;
    }
  }
}
