import 'dart:convert';
import 'package:attendance_app/shared/shared_value.dart';
import 'package:http/http.dart' as http;

class AttendanceRepository {
  // Ingat: Gunakan 10.0.2.2 untuk Android Emulator, atau IP Lokal jika pakai HP Asli

  Future<Map<String, dynamic>> clockIn({
    required String token,
    required double latitude,
    required double longitude,
    required String photoBase64,
  }) async {
    final url = Uri.parse('$baseUrl/attendance/clockin');
    http.Response response;

    try {
      response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // Memasukkan token ke header
        },
        body: jsonEncode({
          // 'latitude': -6.289500,
          // 'longitude': 106.775500,
          'latitude': latitude,
          'longitude': longitude,
          'photo': photoBase64,
        }),
      );
    } catch (e) {
      throw Exception(
        'Tidak dapat terhubung ke server. Pastikan backend Go menyala.',
      );
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      String errorMessage = 'Gagal melakukan absensi.';
      try {
        final errorData = jsonDecode(response.body);

        // print('errorData: $errorData');
        if (errorData['message'] != null) {
          errorMessage = errorData['message'];
        } else if (errorData['error'] != null) {
          errorMessage = errorData['error'];
        }
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }

  Future<Map<String, dynamic>> clockOut({
    required String token,
    required double latitude,
    required double longitude,
    required String photoBase64,
  }) async {
    // Asumsi endpoint untuk pulang adalah /clockout
    final url = Uri.parse('$baseUrl/attendance/clockout');
    http.Response response;

    try {
      response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          // 'latitude': latitude,
          // 'longitude': longitude,
          'latitude': -6.289500,
          'longitude': 106.775500,
          'photo': photoBase64,
        }),
      );
    } catch (e) {
      throw Exception('Tidak dapat terhubung ke server.');
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      String errorMessage = 'Gagal melakukan absensi pulang.';
      try {
        final errorData = jsonDecode(response.body);

        // print('errorData: $errorData');
        if (errorData['message'] != null) {
          errorMessage = errorData['message'];
        } else if (errorData['error'] != null) {
          errorMessage = errorData['error'];
        }
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }

  // Tambahkan fungsi ini di bawah fungsi clockIn / clockOut sebelumnya
  Future<Map<String, dynamic>> getTodayHistory(String token) async {
    // Asumsi endpoint API Go Anda untuk riwayat hari ini adalah /today
    final url = Uri.parse('$baseUrl/attendance/today');

    final response = await http.get(
      url,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal mengambil data riwayat hari ini');
    }
  }

  Future<List<dynamic>> getAttendanceHistory(String token) async {
    // Asumsi endpoint API Go Anda untuk riwayat semua hari adalah /history atau /
    // Sesuaikan URL ini jika backend Anda menggunakan endpoint yang berbeda
    final url = Uri.parse('$baseUrl/attendance/history');

    final response = await http.get(
      url,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      // Asumsi backend mengembalikan { "data": [ {..}, {..} ] }
      return decoded['data'] ?? [];
    } else {
      throw Exception('Gagal mengambil data riwayat absensi');
    }
  }

  Future<List<dynamic>> getAllAttendance(String token) async {
    // Sesuaikan dengan URL endpoint admin Anda
    final url = Uri.parse('$baseUrl/attendance/all');

    final response = await http.get(
      url,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded['data'] ?? [];
    } else {
      throw Exception('Gagal mengambil seluruh data absensi');
    }
  }
}
