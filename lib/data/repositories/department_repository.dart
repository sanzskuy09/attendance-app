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
}
