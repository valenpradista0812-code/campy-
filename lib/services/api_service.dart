import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../data.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:5000';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:5000';
    } catch (_) {}
    return 'http://localhost:5000';
  }

  static String? userToken;

  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        if (userToken != null) 'Authorization': 'Bearer $userToken',
      };

  /// Check backend connection health
  static Future<bool> isBackendConnected() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 2));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Login user
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: headers,
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        userToken = data['data']?['accessToken'];
        return {'success': true, 'data': data['data']};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Login failed',
      };
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to backend: $e'};
    }
  }

  /// Register user
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: headers,
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
          'phone': phone,
        }),
      );

      final data = jsonDecode(res.body);
      if (res.statusCode == 201 && data['success'] == true) {
        // Jika email perlu dikonfirmasi, kirim info itu ke UI
        return {
          'success': true,
          'data': data['data'],
          'requiresEmailConfirmation': data['requiresEmailConfirmation'] ?? false,
          'message': data['message'],
        };
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Registration failed',
      };
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to backend: $e'};
    }
  }

  /// Calculate checkout with delivery fee from backend
  static Future<Map<String, dynamic>?> calculateCheckout({
    required List<CartItem> items,
    required String deliveryMethod, // 'pickup' | 'delivery'
  }) async {
    try {
      final body = {
        'deliveryMethod': deliveryMethod,
        'items': items
            .map((e) => {
                  'name': e.product.name,
                  'qty': e.qty,
                  'price': e.unitPrice,
                })
            .toList(),
      };

      final res = await http.post(
        Uri.parse('$baseUrl/api/checkout/calculate'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['data'];
      }
    } catch (_) {}
    return null;
  }

  /// Create order on backend
  static Future<bool> createOrder({
    required String productName,
    required String productSub,
    required int qty,
    required int unitPrice,
    required String deliveryMethod,
    required String paymentMethod,
    String? deliveryAddress,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/orders'),
        headers: headers,
        body: jsonEncode({
          'productName': productName,
          'productSub': productSub,
          'qty': qty,
          'unitPrice': unitPrice,
          'deliveryMethod': deliveryMethod,
          'paymentMethod': paymentMethod,
          'deliveryAddress': deliveryAddress,
        }),
      );
      return res.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  /// Record payment transaction on backend
  static Future<bool> createTransaction({
    required String orderId,
    required int amount,
    required String paymentMethod,
    required bool isSuccess,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/transactions'),
        headers: headers,
        body: jsonEncode({
          'orderId': orderId,
          'amount': amount,
          'paymentMethod': paymentMethod,
          'status': isSuccess ? 'success' : 'failed',
        }),
      );
      return res.statusCode == 201;
    } catch (_) {
      return false;
    }
  }
}
