import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data.dart';
import '../staff_data.dart';

class ApiService {
  /// Base API URL dynamically derived from compile-time environment or sensible platform defaults
  static String get baseUrl {
    const customUrl = String.fromEnvironment('API_URL');
    if (customUrl.isNotEmpty) return customUrl;
    return 'https://backend-campy-production.up.railway.app';
  }

  // Auth tokens & role in memory
  static String? userToken;
  static String? userRefreshToken;
  static String? currentUserRole;
  static String? currentUserEmail;
  static String? currentUserName;
  static String? lastError;
  static VoidCallback? onSessionExpired;

  static const String _keyToken = 'campy_access_token';
  static const String _keyRefresh = 'campy_refresh_token';
  static const String _keyRole = 'campy_user_role';
  static const String _keyEmail = 'campy_user_email';
  static const String _keyName = 'campy_user_name';

  /// Initialize persistent storage on application startup
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      userToken = prefs.getString(_keyToken);
      userRefreshToken = prefs.getString(_keyRefresh);
      currentUserRole = prefs.getString(_keyRole) ?? 'user';
      currentUserEmail = prefs.getString(_keyEmail);
      currentUserName = prefs.getString(_keyName);
    } catch (e) {
      debugPrint('Error loading SharedPreferences: $e');
    }
  }

  /// Save authentication session into SharedPreferences
  static Future<void> saveAuth({
    required String token,
    String? refreshToken,
    String? role,
    String? email,
    String? name,
  }) async {
    userToken = token;
    if (refreshToken != null) userRefreshToken = refreshToken;
    if (role != null) currentUserRole = role;
    if (email != null) currentUserEmail = email;
    if (name != null) currentUserName = name;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyToken, token);
      if (refreshToken != null) {
        await prefs.setString(_keyRefresh, refreshToken);
      }
      if (role != null) await prefs.setString(_keyRole, role);
      if (email != null) await prefs.setString(_keyEmail, email);
      if (name != null) await prefs.setString(_keyName, name);
    } catch (e) {
      debugPrint('Error saving SharedPreferences: $e');
    }
  }

  /// Clear persistent auth data on logout
  static Future<void> logout() async {
    userToken = null;
    userRefreshToken = null;
    currentUserRole = null;
    currentUserEmail = null;
    currentUserName = null;
    cartNotifier.value = [];
    wishlistNotifier.value = [];

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyToken);
      await prefs.remove(_keyRefresh);
      await prefs.remove(_keyRole);
      await prefs.remove(_keyEmail);
      await prefs.remove(_keyName);
    } catch (_) {}
  }

  static bool get isAuthenticated => userToken != null && userToken!.isNotEmpty;
  static bool get isSuperAdmin =>
      currentUserRole == 'super_admin' || currentUserRole == 'superadmin';

  static String _responseMessage(http.Response response, String fallback) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body['message'] is String) {
        return body['message'] as String;
      }
    } catch (_) {}
    return fallback;
  }

  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    if (userToken != null) 'Authorization': 'Bearer $userToken',
  };

  /// Check backend connection health
  static Future<bool> isBackendConnected() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 4));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Centralized HTTP request with automatic token refresh on 401
  static Future<http.Response> _sendWithAuthRetry(
    String method,
    Uri uri, {
    Map<String, String>? extraHeaders,
    Object? body,
  }) async {
    final mergedHeaders = {
      ...headers,
      if (extraHeaders != null) ...extraHeaders,
    };

    http.Response res;
    switch (method.toUpperCase()) {
      case 'POST':
        res = await http.post(uri, headers: mergedHeaders, body: body);
        break;
      case 'PUT':
        res = await http.put(uri, headers: mergedHeaders, body: body);
        break;
      case 'PATCH':
        res = await http.patch(uri, headers: mergedHeaders, body: body);
        break;
      case 'DELETE':
        res = await http.delete(uri, headers: mergedHeaders, body: body);
        break;
      case 'GET':
      default:
        res = await http.get(uri, headers: mergedHeaders);
        break;
    }

    // If 401 Unauthorized, attempt refresh once
    if (res.statusCode == 401 &&
        userRefreshToken != null &&
        userRefreshToken!.isNotEmpty) {
      final refreshed = await _refreshAccessToken();
      if (refreshed) {
        final retryHeaders = {
          ...headers,
          if (extraHeaders != null) ...extraHeaders,
        };
        switch (method.toUpperCase()) {
          case 'POST':
            return await http.post(uri, headers: retryHeaders, body: body);
          case 'PUT':
            return await http.put(uri, headers: retryHeaders, body: body);
          case 'PATCH':
            return await http.patch(uri, headers: retryHeaders, body: body);
          case 'DELETE':
            return await http.delete(uri, headers: retryHeaders, body: body);
          case 'GET':
          default:
            return await http.get(uri, headers: retryHeaders);
        }
      }
      await logout();
      onSessionExpired?.call();
    } else if (res.statusCode == 401 && isAuthenticated) {
      await logout();
      onSessionExpired?.call();
    }

    return res;
  }

  /// Helper to refresh access token using refresh_token
  static Future<bool> _refreshAccessToken() async {
    try {
      if (userRefreshToken == null) return false;
      final res = await http.post(
        Uri.parse('$baseUrl/api/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': userRefreshToken}),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true && data['data']?['accessToken'] != null) {
          await saveAuth(
            token: data['data']['accessToken'],
            refreshToken: data['data']['refreshToken'],
          );
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  // ===========================================================================
  // AUTHENTICATION
  // ===========================================================================

  /// Login user
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: headers,
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        final token = data['data']?['accessToken'];
        final refresh = data['data']?['refreshToken'];
        final role = data['data']?['role'] ?? 'user';
        final user = data['data']?['user'];
        final profile = data['data']?['profile'];

        await saveAuth(
          token: token ?? '',
          refreshToken: refresh,
          role: role,
          email: user?['email'],
          name: profile?['full_name'] ?? user?['user_metadata']?['name'],
        );

        return {'success': true, 'data': data['data']};
      }
      return {'success': false, 'message': data['message'] ?? 'Login gagal.'};
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal terhubung ke server backend: $e',
      };
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
        final token = data['data']?['accessToken'];
        if (token != null) {
          await saveAuth(
            token: token,
            refreshToken: data['data']?['refreshToken'],
            role: 'user',
            email: email,
            name: name,
          );
        }
        return {
          'success': true,
          'data': data['data'],
          'requiresEmailConfirmation':
              data['requiresEmailConfirmation'] ?? false,
          'message': data['message'] ?? 'Registrasi berhasil.',
        };
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Registrasi gagal.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal terhubung ke server backend: $e',
      };
    }
  }

  /// Register Super Admin account
  static Future<Map<String, dynamic>> registerSuperAdmin({
    required String email,
    required String password,
    required String name,
    String? phone,
    String? detail,
    String? location,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: headers,
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
          'phone': phone ?? '',
          'role': 'super_admin',
          'detail': detail ?? 'Super Administrator',
          'location': location ?? 'Campy HQ',
        }),
      );

      final data = jsonDecode(res.body);
      if (res.statusCode == 201 && data['success'] == true) {
        final token = data['data']?['accessToken'];
        if (token != null) {
          await saveAuth(
            token: token,
            refreshToken: data['data']?['refreshToken'],
            role: 'super_admin',
            email: email,
            name: name,
          );
        }
        return {
          'success': true,
          'data': data['data'],
          'message': data['message'] ?? 'Registrasi Super Admin berhasil!',
        };
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Registrasi Super Admin gagal.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal terhubung ke server backend: $e',
      };
    }
  }

  /// Staff login (Admin & Petugas)
  static Future<Map<String, dynamic>> staffLogin({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/auth/staff-login'),
        headers: headers,
        body: jsonEncode({'email': email, 'password': password, 'role': role}),
      );

      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        final token = data['data']?['accessToken'];
        final refresh = data['data']?['refreshToken'];
        final name = data['data']?['name'];

        await saveAuth(
          token: token ?? '',
          refreshToken: refresh,
          role: role,
          email: email,
          name: name,
        );

        return {'success': true, 'data': data['data']};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Login staff gagal.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke backend: $e'};
    }
  }

  /// Get current user profile
  static Future<Map<String, dynamic>?> getProfile() async {
    try {
      final res = await _sendWithAuthRetry(
        'GET',
        Uri.parse('$baseUrl/api/auth/profile'),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        currentUserName = data['data']?['full_name'] as String?;
        currentUserEmail = data['data']?['email'] as String?;
        lastError = null;
        return data['data'];
      }
      lastError = _responseMessage(res, 'Gagal memuat profil.');
    } catch (e) {
      lastError = 'Gagal memuat profil: $e';
    }
    return null;
  }

  /// Update current user profile
  static Future<bool> updateProfile({
    String? fullName,
    String? phone,
    String? address,
    String? avatarUrl,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (fullName != null) body['full_name'] = fullName;
      if (phone != null) body['phone'] = phone;
      if (address != null) body['address'] = address;
      if (avatarUrl != null) body['avatar_url'] = avatarUrl;

      final res = await _sendWithAuthRetry(
        'PUT',
        Uri.parse('$baseUrl/api/auth/profile'),
        body: jsonEncode(body),
      );
      final succeeded = res.statusCode == 200;
      lastError = succeeded
          ? null
          : _responseMessage(res, 'Gagal menyimpan profil.');
      if (succeeded && fullName != null) {
        currentUserName = fullName;
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_keyName, fullName);
        } catch (e) {
          debugPrint('Gagal menyimpan nama profil di perangkat: $e');
        }
      }
      return succeeded;
    } catch (e) {
      lastError = 'Gagal menyimpan profil: $e';
      return false;
    }
  }

  // ===========================================================================
  // PRODUCTS & CATALOG
  // ===========================================================================

  /// Get list of products with optional query parameters
  static Future<List<Product>> getProducts({
    String? category,
    String? q,
    String? sort,
    bool? specialOffer,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (q != null && q.isNotEmpty) queryParams['q'] = q;
      if (sort != null && sort.isNotEmpty) queryParams['sort'] = sort;
      if (specialOffer != null) {
        queryParams['special_offers'] = specialOffer.toString();
      }

      final uri = Uri.parse(
        '$baseUrl/api/products',
      ).replace(queryParameters: queryParams.isEmpty ? null : queryParams);
      final res = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 6));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true && data['data'] is List) {
          lastError = null;
          final list = (data['data'] as List)
              .map((p) => Product.fromJson(p as Map<String, dynamic>))
              .toList();
          return list;
        }
      }
      lastError = _responseMessage(res, 'Gagal memuat katalog produk.');
    } catch (e) {
      lastError = 'Gagal terhubung ke server saat memuat katalog: $e';
      debugPrint(lastError);
    }
    return [];
  }

  /// Get single product by ID
  static Future<Product?> getProduct(String id) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/api/products/$id'),
        headers: headers,
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['data'] != null) {
          lastError = null;
          return Product.fromJson(data['data']);
        }
      }
      lastError = _responseMessage(res, 'Produk tidak ditemukan.');
    } catch (e) {
      lastError = 'Gagal memuat detail produk: $e';
    }
    return null;
  }

  // ===========================================================================
  // WISHLIST
  // ===========================================================================

  /// Get current user's wishlist products
  static Future<List<Product>> getWishlist() async {
    try {
      final res = await _sendWithAuthRetry(
        'GET',
        Uri.parse('$baseUrl/api/wishlist'),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true && data['data'] is List) {
          lastError = null;
          final list = (data['data'] as List).map((w) {
            if (w['product'] is Map<String, dynamic>) {
              return Product.fromJson(w['product']);
            }
            return Product.fromJson(w as Map<String, dynamic>);
          }).toList();
          return list;
        }
      }
      lastError = _responseMessage(res, 'Gagal memuat wishlist.');
    } catch (e) {
      lastError = 'Gagal memuat wishlist: $e';
      debugPrint(lastError);
    }
    return [];
  }

  /// Add product to wishlist
  static Future<bool> addWishlist(String productId) async {
    try {
      final res = await _sendWithAuthRetry(
        'POST',
        Uri.parse('$baseUrl/api/wishlist'),
        body: jsonEncode({'productId': productId}),
      );
      final succeeded = res.statusCode == 200 || res.statusCode == 201;
      lastError = succeeded
          ? null
          : _responseMessage(res, 'Gagal menambahkan wishlist.');
      return succeeded;
    } catch (e) {
      lastError = 'Gagal menambahkan wishlist: $e';
      return false;
    }
  }

  /// Remove product from wishlist
  static Future<bool> removeWishlist(String productId) async {
    try {
      final res = await _sendWithAuthRetry(
        'DELETE',
        Uri.parse('$baseUrl/api/wishlist/$productId'),
      );
      final succeeded = res.statusCode == 200;
      lastError = succeeded
          ? null
          : _responseMessage(res, 'Gagal menghapus wishlist.');
      return succeeded;
    } catch (e) {
      lastError = 'Gagal menghapus wishlist: $e';
      return false;
    }
  }

  // ===========================================================================
  // CHECKOUT & ORDERS
  // ===========================================================================

  /// Calculate checkout with delivery fee derived directly from database
  static Future<Map<String, dynamic>?> calculateCheckout({
    required List<CartItem> items,
    required String deliveryMethod,
  }) async {
    try {
      final body = {
        'deliveryMethod': deliveryMethod,
        'items': items
            .map(
              (e) => {
                'productId': e.product.id,
                'name': e.product.name,
                'qty': e.qty,
              },
            )
            .toList(),
      };

      final res = await http.post(
        Uri.parse('$baseUrl/api/checkout/calculate'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        lastError = null;
        return data['data'];
      }
      lastError = _responseMessage(res, 'Gagal menghitung total checkout.');
    } catch (e) {
      lastError = 'Gagal menghitung total checkout: $e';
    }
    return null;
  }

  /// Create order on backend (calls atomic RPC create_order in Supabase)
  static Future<Map<String, dynamic>> createOrder({
    required List<CartItem> items,
    required String deliveryMethod,
    required String paymentMethod,
    String? deliveryAddress,
  }) async {
    try {
      final mappedItems = items
          .map(
            (e) => {
              'productId': e.product.id,
              'name': e.product.name,
              'qty': e.qty,
            },
          )
          .toList();

      final res = await _sendWithAuthRetry(
        'POST',
        Uri.parse('$baseUrl/api/orders'),
        body: jsonEncode({
          'items': mappedItems,
          'deliveryMethod': deliveryMethod,
          'paymentMethod': paymentMethod,
          'deliveryAddress': deliveryAddress,
        }),
      );

      final data = jsonDecode(res.body);
      if (res.statusCode == 201 && data['success'] == true) {
        lastError = null;
        return {
          'success': true,
          'data': data['data'],
          'orderId': data['data']?['id'],
        };
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal membuat pesanan.',
      };
    } catch (e) {
      lastError = 'Gagal menghubungi server pesanan: $e';
      return {'success': false, 'message': lastError};
    }
  }

  /// Get list of orders
  static Future<List<AppOrder>> getOrders({String? status}) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/api/orders',
      ).replace(queryParameters: status != null ? {'status': status} : null);
      final res = await _sendWithAuthRetry('GET', uri);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['data'] is List) {
          lastError = null;
          return (data['data'] as List)
              .map((o) => AppOrder.fromJson(o as Map<String, dynamic>))
              .toList();
        }
      }
      lastError = _responseMessage(res, 'Gagal memuat pesanan.');
    } catch (e) {
      lastError = 'Gagal memuat pesanan: $e';
      debugPrint(lastError);
    }
    return [];
  }

  /// Update order status (Admin / Petugas / User cancellation)
  static Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      final res = await _sendWithAuthRetry(
        'PATCH',
        Uri.parse('$baseUrl/api/orders/$orderId/status'),
        body: jsonEncode({'status': status}),
      );
      final succeeded = res.statusCode == 200;
      lastError = succeeded
          ? null
          : _responseMessage(res, 'Gagal memperbarui status pesanan.');
      return succeeded;
    } catch (e) {
      lastError = 'Gagal memperbarui status pesanan: $e';
      return false;
    }
  }

  // ===========================================================================
  // TRANSACTIONS
  // ===========================================================================

  /// Record payment transaction on backend
  static Future<Map<String, dynamic>> createTransaction({
    required String orderId,
    required int amount,
    required String paymentMethod,
    required bool isSuccess,
    String? recipient,
  }) async {
    try {
      final res = await _sendWithAuthRetry(
        'POST',
        Uri.parse('$baseUrl/api/transactions'),
        body: jsonEncode({
          'orderId': orderId,
          'amount': amount,
          'paymentMethod': paymentMethod,
          'status': isSuccess ? 'success' : 'failed',
          'recipient': recipient,
        }),
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 201 && data['success'] == true) {
        lastError = null;
        return {'success': true, 'data': data['data']};
      }
      lastError = data['message'] as String? ?? 'Gagal mencatat transaksi.';
      return {'success': false, 'message': lastError};
    } catch (e) {
      lastError = 'Gagal mencatat transaksi: $e';
      return {'success': false, 'message': lastError};
    }
  }

  /// Get transactions history
  static Future<List<AppTransaction>> getTransactions({String? status}) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/api/transactions',
      ).replace(queryParameters: status != null ? {'status': status} : null);
      final res = await _sendWithAuthRetry('GET', uri);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['data'] is List) {
          lastError = null;
          return (data['data'] as List)
              .map((t) => AppTransaction.fromJson(t as Map<String, dynamic>))
              .toList();
        }
      }
      lastError = _responseMessage(res, 'Gagal memuat riwayat transaksi.');
    } catch (e) {
      lastError = 'Gagal memuat riwayat transaksi: $e';
      debugPrint(lastError);
    }
    return [];
  }

  // ===========================================================================
  // ADMIN MANAGEMENT
  // ===========================================================================

  /// Get list of admin users
  static Future<List<AdminUser>> getAdmins({String? query}) async {
    try {
      final uri = Uri.parse('$baseUrl/api/admins').replace(
        queryParameters: query != null && query.isNotEmpty
            ? {'q': query}
            : null,
      );
      final res = await _sendWithAuthRetry('GET', uri);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['data'] is List) {
          lastError = null;
          return (data['data'] as List)
              .map((a) => AdminUser.fromJson(a as Map<String, dynamic>))
              .toList();
        }
      }
      lastError = _responseMessage(res, 'Gagal memuat daftar admin.');
    } catch (e) {
      lastError = 'Gagal memuat daftar admin: $e';
      debugPrint(lastError);
    }
    return [];
  }

  /// Create or promote admin (role: 'admin' or 'super_admin')
  static Future<AdminUser?> createAdmin({
    required String username,
    required String email,
    String? detail,
    String? location,
    String? password,
    String role = 'admin',
  }) async {
    try {
      final res = await _sendWithAuthRetry(
        'POST',
        Uri.parse('$baseUrl/api/admins'),
        body: jsonEncode({
          'username': username,
          'email': email,
          'detail': detail,
          'location': location,
          'password': password,
          'role': role,
        }),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);
        if (data['data'] != null) {
          lastError = null;
          return AdminUser.fromJson(data['data']);
        }
      }
      lastError = _responseMessage(res, 'Gagal menambahkan admin.');
    } catch (e) {
      lastError = 'Gagal menambahkan admin: $e';
    }
    return null;
  }

  /// Update admin
  static Future<bool> updateAdmin({
    required dynamic id,
    String? username,
    String? email,
    String? detail,
    String? location,
  }) async {
    try {
      final res = await _sendWithAuthRetry(
        'PUT',
        Uri.parse('$baseUrl/api/admins/$id'),
        body: jsonEncode({
          if (username != null) 'username': username,
          if (email != null) 'email': email,
          if (detail != null) 'detail': detail,
          if (location != null) 'location': location,
        }),
      );
      final succeeded = res.statusCode == 200;
      lastError = succeeded
          ? null
          : _responseMessage(res, 'Gagal memperbarui admin.');
      return succeeded;
    } catch (e) {
      lastError = 'Gagal memperbarui admin: $e';
      return false;
    }
  }

  /// Delete admin
  static Future<bool> deleteAdmin(dynamic id) async {
    try {
      final res = await _sendWithAuthRetry(
        'DELETE',
        Uri.parse('$baseUrl/api/admins/$id'),
      );
      final succeeded = res.statusCode == 200;
      lastError = succeeded
          ? null
          : _responseMessage(res, 'Gagal menghapus admin.');
      return succeeded;
    } catch (e) {
      lastError = 'Gagal menghapus admin: $e';
      return false;
    }
  }

  // ===========================================================================
  // PETUGAS ACCOUNTS MANAGEMENT (BY ADMIN)
  // ===========================================================================

  /// Get list of petugas accounts
  static Future<List<AdminUser>> getPetugasList({String? query}) async {
    try {
      final uri = Uri.parse('$baseUrl/api/admins/petugas').replace(
        queryParameters: query != null && query.isNotEmpty
            ? {'q': query}
            : null,
      );
      final res = await _sendWithAuthRetry('GET', uri);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['data'] is List) {
          lastError = null;
          return (data['data'] as List)
              .map((p) => AdminUser.fromJson(p as Map<String, dynamic>))
              .toList();
        }
      }
      lastError = _responseMessage(res, 'Gagal memuat daftar petugas.');
    } catch (e) {
      lastError = 'Gagal memuat daftar petugas: $e';
      debugPrint(lastError);
    }
    return [];
  }

  /// Create new petugas account by Admin
  static Future<AdminUser?> createPetugas({
    required String username,
    required String email,
    required String password,
    String? phone,
    String? detail,
    String? location,
  }) async {
    try {
      final res = await _sendWithAuthRetry(
        'POST',
        Uri.parse('$baseUrl/api/admins/petugas'),
        body: jsonEncode({
          'username': username,
          'name': username,
          'email': email,
          'password': password,
          'phone': phone,
          'detail': detail,
          'location': location,
        }),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);
        if (data['data'] != null) {
          lastError = null;
          return AdminUser.fromJson(data['data']);
        }
      }
      lastError = _responseMessage(res, 'Gagal menambahkan petugas.');
    } catch (e) {
      lastError = 'Gagal menambahkan petugas: $e';
    }
    return null;
  }

  /// Update petugas account by Admin
  static Future<bool> updatePetugas({
    required dynamic id,
    String? username,
    String? email,
    String? phone,
    String? detail,
    String? location,
  }) async {
    try {
      final res = await _sendWithAuthRetry(
        'PUT',
        Uri.parse('$baseUrl/api/admins/petugas/$id'),
        body: jsonEncode({
          if (username != null) 'username': username,
          if (username != null) 'name': username,
          if (email != null) 'email': email,
          if (phone != null) 'phone': phone,
          if (detail != null) 'detail': detail,
          if (location != null) 'location': location,
        }),
      );
      final succeeded = res.statusCode == 200;
      lastError = succeeded
          ? null
          : _responseMessage(res, 'Gagal memperbarui petugas.');
      return succeeded;
    } catch (e) {
      lastError = 'Gagal memperbarui petugas: $e';
      return false;
    }
  }

  /// Delete petugas account by Admin
  static Future<bool> deletePetugas(dynamic id) async {
    try {
      final res = await _sendWithAuthRetry(
        'DELETE',
        Uri.parse('$baseUrl/api/admins/petugas/$id'),
      );
      final succeeded = res.statusCode == 200;
      lastError = succeeded
          ? null
          : _responseMessage(res, 'Gagal menghapus petugas.');
      return succeeded;
    } catch (e) {
      lastError = 'Gagal menghapus petugas: $e';
      return false;
    }
  }

  // ===========================================================================
  // PETUGAS STOCK MANAGEMENT
  // ===========================================================================

  /// Get inventory stock items
  static Future<List<StockItem>> getStock({String? query}) async {
    try {
      final uri = Uri.parse('$baseUrl/api/petugas/stock').replace(
        queryParameters: query != null && query.isNotEmpty
            ? {'q': query}
            : null,
      );
      final res = await _sendWithAuthRetry('GET', uri);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['data'] is List) {
          lastError = null;
          return (data['data'] as List)
              .map((s) => StockItem.fromJson(s as Map<String, dynamic>))
              .toList();
        }
      }
      lastError = _responseMessage(res, 'Gagal memuat stok.');
    } catch (e) {
      lastError = 'Gagal memuat stok: $e';
      debugPrint(lastError);
    }
    return [];
  }

  /// Add stock item
  static Future<StockItem?> addStock({
    required String name,
    required int qty,
    required int price,
    String? icon,
    String? imageUrl,
    String? sub,
    String? category,
    String? categorySlug,
    bool isSpecialOffer = false,
    String? description,
  }) async {
    try {
      final res = await _sendWithAuthRetry(
        'POST',
        Uri.parse('$baseUrl/api/petugas/stock'),
        body: jsonEncode({
          'name': name,
          'qty': qty,
          'price': price,
          if (icon != null) 'icon': icon,
          if (imageUrl != null) 'image_url': imageUrl,
          if (sub != null) 'sub': sub,
          if (category != null) 'category': category,
          if (categorySlug != null) 'category_slug': categorySlug,
          'is_special_offer': isSpecialOffer,
          if (description != null) 'description': description,
        }),
      );

      if (res.statusCode == 201 || res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['data'] != null) {
          lastError = null;
          return StockItem.fromJson(data['data']);
        }
      }
      lastError = _responseMessage(res, 'Gagal menambahkan stok.');
    } catch (e) {
      lastError = 'Gagal menambahkan stok: $e';
    }
    return null;
  }

  /// Update stock item
  static Future<bool> updateStock({
    required dynamic id,
    String? name,
    int? qty,
    int? price,
    String? icon,
    String? imageUrl,
    String? sub,
    String? category,
    String? categorySlug,
    bool? isSpecialOffer,
    String? description,
  }) async {
    try {
      final res = await _sendWithAuthRetry(
        'PUT',
        Uri.parse('$baseUrl/api/petugas/stock/$id'),
        body: jsonEncode({
          if (name != null) 'name': name,
          if (qty != null) 'qty': qty,
          if (price != null) 'price': price,
          if (icon != null) 'icon': icon,
          if (imageUrl != null) 'image_url': imageUrl,
          if (sub != null) 'sub': sub,
          if (category != null) 'category': category,
          if (categorySlug != null) 'category_slug': categorySlug,
          if (isSpecialOffer != null) 'is_special_offer': isSpecialOffer,
          if (description != null) 'description': description,
        }),
      );
      final succeeded = res.statusCode == 200;
      lastError = succeeded
          ? null
          : _responseMessage(res, 'Gagal memperbarui stok.');
      return succeeded;
    } catch (e) {
      lastError = 'Gagal memperbarui stok: $e';
      return false;
    }
  }

  /// Delete stock item
  static Future<bool> deleteStock(dynamic id) async {
    try {
      final res = await _sendWithAuthRetry(
        'DELETE',
        Uri.parse('$baseUrl/api/petugas/stock/$id'),
      );
      final succeeded = res.statusCode == 200;
      lastError = succeeded
          ? null
          : _responseMessage(res, 'Gagal menghapus stok.');
      return succeeded;
    } catch (e) {
      lastError = 'Gagal menghapus stok: $e';
      return false;
    }
  }

  // ===========================================================================
  // IMAGE UPLOAD
  // ===========================================================================

  /// Upload image bytes to Supabase Storage bucket via /api/upload
  static Future<String?> uploadImage(Uint8List bytes, String filename) async {
    try {
      final uri = Uri.parse('$baseUrl/api/upload');
      final request = http.MultipartRequest('POST', uri);

      if (userToken != null) {
        request.headers['Authorization'] = 'Bearer $userToken';
      }

      final ext = filename.split('.').last.toLowerCase();
      final mimeType = ext == 'png'
          ? MediaType('image', 'png')
          : ext == 'webp'
              ? MediaType('image', 'webp')
              : ext == 'gif'
                  ? MediaType('image', 'gif')
                  : MediaType('image', 'jpeg');

      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: filename,
          contentType: mimeType,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        lastError = null;
        var url = data['data']?['url'] as String?;
        if (url != null && url.startsWith('/')) {
          url = '$baseUrl$url';
        }
        return url;
      }
      lastError = _responseMessage(response, 'Gagal mengunggah gambar.');
    } catch (e) {
      lastError = 'Gagal mengunggah gambar: $e';
      debugPrint(lastError);
    }
    return null;
  }

  // ===========================================================================
  // CAMPY GEMINI AI ASSISTANT
  // ===========================================================================

  static const String geminiApiKey =
      String.fromEnvironment('GEMINI_API_KEY');
  static const String geminiModel = 'gemini-3.5-flash-lite';

  /// Tanya Campy AI Assistant menggunakan Gemini API
  static Future<String> askCampyAi(
    String message, {
    List<Map<String, String>> history = const [],
  }) async {
    // 1. Coba lewat backend /api/ai/chat terlebih dahulu
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/api/ai/chat'),
            headers: {
              'Content-Type': 'application/json',
              if (userToken != null) 'Authorization': 'Bearer $userToken',
            },
            body: jsonEncode({
              'message': message,
              'history': history,
            }),
          )
          .timeout(const Duration(seconds: 12));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final reply = data['data']?['reply'] as String?;
        if (reply != null && reply.trim().isNotEmpty) {
          return reply.trim();
        }
      }
    } catch (_) {
      // Backend offline atau timeout, gunakan fallback langsung ke Gemini API jika key tersedia
    }

    // 2. Fallback langsung ke Google Gemini API jika GEMINI_API_KEY disediakan di frontend
    if (geminiApiKey.isEmpty) {
      return 'Maaf, tidak dapat terhubung ke Campy AI saat ini. Pastikan server backend sedang online.';
    }
    try {
      final geminiUri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$geminiModel:generateContent?key=$geminiApiKey',
      );

      final contents = <Map<String, dynamic>>[];

      // Tambahkan instruksi sistem
      contents.add({
        'role': 'user',
        'parts': [
          {
            'text':
                'Peranmu: Kamu adalah Campy AI Assistant, asisten ramah dan ahli perlengkapan camping/hiking di Campy. Bantu pengguna dengan rekomendasi tenda, perlengkapan outdoor, tips mendaki gunung, memasak di alam bebas, dan keselamatan camping dengan bahasa Indonesia yang ramah, sopan, dan jelas.'
          }
        ],
      });
      contents.add({
        'role': 'model',
        'parts': [
          {
            'text':
                'Halo! Saya Campy AI Assistant. Siap membantu Anda memilih perlengkapan camping dan merencanakan petualangan outdoor terbaik!'
          }
        ],
      });

      // Tambahkan riwayat obrolan
      for (final h in history) {
        final role = h['role'] == 'user' ? 'user' : 'model';
        final text = h['text'] ?? '';
        if (text.isNotEmpty) {
          contents.add({
            'role': role,
            'parts': [
              {'text': text}
            ],
          });
        }
      }

      // Tambahkan pesan user terkini
      contents.add({
        'role': 'user',
        'parts': [
          {'text': message}
        ],
      });

      final res = await http
          .post(
            geminiUri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'contents': contents}),
          )
          .timeout(const Duration(seconds: 15));

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body);
        final reply =
            data['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;
        if (reply != null && reply.trim().isNotEmpty) {
          return reply.trim();
        }
      } else {
        final err = jsonDecode(res.body);
        return 'Maaf, terjadi kendala saat menghubungi Gemini AI: ${err['error']?['message'] ?? 'Status ${res.statusCode}'}';
      }
    } catch (e) {
      return 'Maaf, tidak dapat terhubung ke Campy AI saat ini ($e). Silakan periksa koneksi internet Anda.';
    }

    return 'Maaf, Campy AI belum dapat memberikan respon untuk saat ini.';
  }
}
