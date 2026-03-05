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
}
