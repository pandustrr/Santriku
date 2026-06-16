import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:santriku_app/core/core.dart';
import 'package:santriku_app/features/auth/services/auth_service.dart';

class PengurusService {
  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${AuthService.token}',
      };

  /// Fetch all permissions
  static Future<List<Map<String, dynamic>>> getPermissions() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/pengurus/permissions'),
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

  /// Approve/Reject permission
  static Future<Map<String, dynamic>> updatePermissionStatus(int id, String status) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/pengurus/permissions/$id'),
        headers: _headers,
        body: jsonEncode({'status': status}),
      );

      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': body['message'] ?? 'Status perizinan berhasil diperbarui',
          'perizinan': body['perizinan'],
        };
      }
      return {
        'success': false,
        'message': body['message'] ?? 'Gagal memperbarui status perizinan',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Kesalahan jaringan: $e',
      };
    }
  }

  /// Fetch consumption statistics
  static Future<Map<String, dynamic>> getConsumptionStats() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/pengurus/consumption-stats'),
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
        'message': 'Gagal mengambil data stok makanan: ${response.statusCode}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Kesalahan jaringan: $e',
      };
    }
  }

  /// Update food portion quota
  static Future<Map<String, dynamic>> updateConsumptionQuota(String jenisMakan, int porsiTotal) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/pengurus/consumption-stats'),
        headers: _headers,
        body: jsonEncode({
          'jenis_makan': jenisMakan,
          'porsi_total': porsiTotal,
        }),
      );

      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': body['message'] ?? 'Kuota porsi makan berhasil diperbarui',
          'stok': body['stok'],
        };
      }
      return {
        'success': false,
        'message': 'Gagal memperbarui kuota porsi makan',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Kesalahan jaringan: $e',
      };
    }
  }

  /// Fetch dashboard statistics
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/pengurus/dashboard-stats'),
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
        'message': 'Gagal mengambil data statistik dashboard: ${response.statusCode}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Kesalahan jaringan: $e',
      };
    }
  }

  /// Fetch recent activity logs
  static Future<List<Map<String, dynamic>>> getActivityLogs() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/pengurus/activity-logs'),
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
