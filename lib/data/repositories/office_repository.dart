import 'dart:convert';
import 'package:attendance_app/shared/shared_value.dart';
import 'package:http/http.dart' as http;

class OfficeRepository {
  // Fungsi READ: Mengambil daftar semua lokasi kantor/toko
  Future<List<dynamic>> getOffices(String token) async {
    final url = Uri.parse('$baseUrl/offices');

    final response = await http.get(
      url,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      // Asumsi format JSON: { "data": [ {"id":1, "name":"Transmart Depok", ...} ] }
      return decoded['data'] ?? [];
    } else {
      throw Exception('Gagal mengambil data office');
    }
  }

  // Fungsi CREATE: Menambah office baru
  Future<bool> createOffice(String token, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/offices');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Gagal menambah data office');
    }
  }

  // Fungsi UPDATE: Mengubah data office
  Future<bool> updateOffice(
    String token,
    int id,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$baseUrl/offices/$id');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Gagal memperbarui data office');
    }
  }

  // Fungsi DELETE: Menghapus data office
  Future<bool> deleteOffice(String token, int id) async {
    final url = Uri.parse('$baseUrl/offices/$id');
    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Gagal menghapus data office');
    }
  }
}
