import 'dart:convert';

import 'package:attendance_app/shared/shared_value.dart';
import 'package:http/http.dart' as http;

class AuthRepository {
  Future<Map<String, dynamic>> login(String nik, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');

    http.Response response;

    // 1. BLOK TRY-CATCH KHUSUS UNTUK NETWORK REQUEST
    try {
      response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'nik': nik, 'password': password}),
      );
    } catch (e) {
      // Jika masuk ke sini, berarti murni masalah koneksi (server Go mati, tidak ada internet, dll)
      print('ERROR NETWORK: $e');
      throw Exception(
        'Tidak dapat terhubung ke server $baseUrl. Pastikan backend menyala.',
      );
    }

    // 2. CEK RESPONSE SERVER DI LUAR BLOK TRY-CATCH NETWORK
    if (response.statusCode == 200) {
      // Jika berhasil
      return jsonDecode(response.body);
    } else {
      // Jika gagal (status code 400, 401, 404, dll)
      String errorMessage = 'Gagal login. Terjadi kesalahan sistem. $baseUrl';

      try {
        final errorData = jsonDecode(response.body);

        // Menyesuaikan dengan response API Anda: {"error": "NIK atau Password salah."}
        if (errorData['error'] != null) {
          errorMessage = errorData['error'];
        }
      } catch (_) {
        // Abaikan jika body ternyata tidak bisa di-parse sebagai JSON
      }

      // Lempar pesan error yang dikirim oleh backend Go Anda
      throw Exception(errorMessage);
    }
  }
}
