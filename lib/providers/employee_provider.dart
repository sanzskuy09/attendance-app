import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/employee_repository.dart';
import 'auth_provider.dart';

final employeeRepositoryProvider = Provider((ref) => EmployeeRepository());

// Provider untuk mengambil daftar karyawan (Otomatis loading & caching)
final employeeListProvider = FutureProvider<List<dynamic>>((ref) async {
  final token = ref.watch(authProvider).token;

  if (token == null) return [];

  final repo = ref.watch(employeeRepositoryProvider);
  try {
    return await repo.getEmployees(token);
  } catch (e) {
    throw Exception(e.toString());
  }
});
