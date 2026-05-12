import 'dart:convert';
import 'package:attendance_app/shared/shared_value.dart';
import 'package:http/http.dart' as http;

class EmployeeRepository {
  // Fungsi READ: Mengambil daftar semua karyawan
  Future<List<dynamic>> getEmployees(String token) async {
    final url = Uri.parse('$baseUrl/users');

    final response = await http.get(
      url,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      // Asumsi format JSON: { "data": [ {"id":1, "name":"Andi", ...} ] }
      return decoded['data'] ?? [];
    } else {
      throw Exception('Gagal mengambil data karyawan');
    }
  }

  Future<bool> createEmployee(
    String token,
    Map<String, dynamic> employeeData,
  ) async {
    final url = Uri.parse('$baseUrl/auth/register');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(employeeData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      String errorMessage =
          'Gagal menambahkan karyawan. Terjadi kesalahan sistem.';

      try {
        final errorData = jsonDecode(response.body);
        if (errorData['message'] != null) {
          errorMessage = errorData['message'];
        }
      } catch (_) {}

      throw Exception(errorMessage);
    }
  }

  // Fungsi UPDATE: Mengubah data karyawan
  Future<bool> updateEmployee(
    String token,
    int id,
    Map<String, dynamic> employeeData,
  ) async {
    final url = Uri.parse('$baseUrl/users/$id');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(employeeData),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      String errorMessage = 'Gagal memperbarui data karyawan';
      try {
        final errorData = jsonDecode(response.body);
        if (errorData['message'] != null) errorMessage = errorData['message'];
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }

  // Fungsi DELETE: Menghapus data karyawan
  Future<bool> deleteEmployee(String token, int id) async {
    final url = Uri.parse('$baseUrl/users/$id');

    final response = await http.delete(
      url,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Gagal menghapus karyawan');
    }
  }
}
