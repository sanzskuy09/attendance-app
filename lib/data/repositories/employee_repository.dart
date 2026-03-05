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

  // Nanti Anda bisa menambahkan fungsi createEmployee, updateEmployee, deleteEmployee di sini
}
