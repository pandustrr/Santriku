import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:santriku_app/core/core.dart';
import 'package:santriku_app/features/auth/services/auth_service.dart';

class WaliService {
  static Map<String, String> get _headers => {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${AuthService.token}',
      };

  /// Fetch linked children list
  static Future<List<Map<String, dynamic>>> getSantris() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/wali/santri'),
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

  /// Fetch dashboard statistics for a specific child
  static Future<Map<String, dynamic>> getDashboardStats(int santriId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/wali/santri/$santriId/dashboard'),
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
        'message': 'Gagal memuat status dashboard anak: ${response.statusCode}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Kesalahan jaringan: $e',
      };
    }
  }

  /// Fetch leave permissions list for a specific child
  static Future<List<Map<String, dynamic>>> getPermissions(int santriId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/wali/santri/$santriId/permissions'),
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

  /// Submit leave permission with optional image attachment
  static Future<Map<String, dynamic>> submitPermission({
    required int santriId,
    required String jenisIzin,
    required String tanggalMulai,
    required String tanggalSelesai,
    required String alasan,
    XFile? buktiFile,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/wali/santri/$santriId/permissions');
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers.addAll(_headers);

      // Add text fields
      request.fields['jenis_izin'] = jenisIzin;
      request.fields['tanggal_mulai'] = tanggalMulai;
      request.fields['tanggal_selesai'] = tanggalSelesai;
      request.fields['alasan'] = alasan;

      // Add file if exists
      if (buktiFile != null) {
        final bytes = await buktiFile.readAsBytes();
        final multipartFile = http.MultipartFile.fromBytes(
          'bukti',
          bytes,
          filename: buktiFile.name,
        );
        request.files.add(multipartFile);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final body = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': body['message'] ?? 'Pengajuan izin berhasil dikirim',
          'perizinan': body['perizinan'],
        };
      }
      return {
        'success': false,
        'message': body['message'] ?? 'Gagal mengirim pengajuan izin',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Kesalahan jaringan: $e',
      };
    }
  }
}
