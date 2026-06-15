import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:santriku_app/core/core.dart';
import 'package:santriku_app/features/auth/services/auth_service.dart';

class AdminService {
  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${AuthService.token}',
      };

  /// Fetch dashboard statistics
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/admin/dashboard-stats'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      }
      return {
        'success': false,
        'message': 'Gagal mengambil statistik dashboard: ${response.statusCode}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Kesalahan jaringan: $e',
      };
    }
  }

  /// Get list of users (Admin, Pengurus, Wali Santri)
  static Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/admin/users'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((item) => Map<String, dynamic>.from(item)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Create a new user (admin, pengurus, wali_santri)
  static Future<Map<String, dynamic>> createUser(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/admin/users'),
        headers: _headers,
        body: jsonEncode(data),
      );

      final body = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': body['message'] ?? 'Pengguna berhasil ditambahkan',
          'user': body['user'],
        };
      }
      return {
        'success': false,
        'message': body['message'] ?? 'Gagal menambahkan pengguna',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Kesalahan jaringan: $e',
      };
    }
  }

  /// Update an existing user
  static Future<Map<String, dynamic>> updateUser(int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/admin/users/$id'),
        headers: _headers,
        body: jsonEncode(data),
      );

      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': body['message'] ?? 'Pengguna berhasil diperbarui',
          'user': body['user'],
        };
      }
      return {
        'success': false,
        'message': body['message'] ?? 'Gagal memperbarui pengguna',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Kesalahan jaringan: $e',
      };
    }
  }

  /// Delete user
  static Future<Map<String, dynamic>> deleteUser(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/admin/users/$id'),
        headers: _headers,
      );

      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': body['message'] ?? 'Pengguna berhasil dihapus',
        };
      }
      return {
        'success': false,
        'message': body['message'] ?? 'Gagal menghapus pengguna',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Kesalahan jaringan: $e',
      };
    }
  }

  /// Get list of all santri
  static Future<List<Map<String, dynamic>>> getSantris() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/admin/santri'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((item) => Map<String, dynamic>.from(item)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Create a new santri profile
  static Future<Map<String, dynamic>> createSantri(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/admin/santri'),
        headers: _headers,
        body: jsonEncode(data),
      );

      final body = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': body['message'] ?? 'Santri berhasil ditambahkan',
          'santri': body['santri'],
        };
      }
      return {
        'success': false,
        'message': body['message'] ?? 'Gagal menambahkan santri',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Kesalahan jaringan: $e',
      };
    }
  }

  /// Update an existing santri
  static Future<Map<String, dynamic>> updateSantri(int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/admin/santri/$id'),
        headers: _headers,
        body: jsonEncode(data),
      );

      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': body['message'] ?? 'Santri berhasil diperbarui',
          'santri': body['santri'],
        };
      }
      return {
        'success': false,
        'message': body['message'] ?? 'Gagal memperbarui santri',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Kesalahan jaringan: $e',
      };
    }
  }

  /// Delete a santri profile
  static Future<Map<String, dynamic>> deleteSantri(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/admin/santri/$id'),
        headers: _headers,
      );

      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': body['message'] ?? 'Santri berhasil dihapus',
        };
      }
      return {
        'success': false,
        'message': body['message'] ?? 'Gagal menghapus santri',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Kesalahan jaringan: $e',
      };
    }
  }

  /// Get monthly attendance report for all students
  static Future<List<Map<String, dynamic>>> getAttendanceReport(int month, int year) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/admin/attendance-report?month=$month&year=$year'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((item) => Map<String, dynamic>.from(item)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
