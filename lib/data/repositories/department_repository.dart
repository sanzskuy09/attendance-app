import 'dart:convert';
import 'package:attendance_app/shared/shared_value.dart';
import 'package:http/http.dart' as http;

class DepartmentRepository {
  // Fungsi READ: Mengambil daftar semua departemen
  Future<List<dynamic>> getDepartments(String token) async {
    final url = Uri.parse('$baseUrl/department');

    final response = await http.get(
      url,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      // Asumsi format JSON: { "data": [ {"id":1, "name":"IT", "description":"..."} ] }
      return decoded['data'] ?? [];
    } else {
      throw Exception('Gagal mengambil data departemen');
    }
  }

  // Fungsi CREATE: Menambah department baru
  Future<bool> createDepartment(String token, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/department');
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
      throw Exception('Gagal menambah department');
    }
  }

  // Fungsi UPDATE: Mengubah data department
  Future<bool> updateDepartment(
    String token,
    int id,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$baseUrl/department/$id');
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
      throw Exception('Gagal memperbarui department');
    }
  }

  // Fungsi DELETE: Menghapus department
  Future<bool> deleteDepartment(String token, int id) async {
    final url = Uri.parse('$baseUrl/department/$id');
    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Gagal menghapus department');
    }
  }
}
