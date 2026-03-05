import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/department_repository.dart';
import 'auth_provider.dart';

final departmentRepositoryProvider = Provider((ref) => DepartmentRepository());

// Provider untuk mengambil daftar department (Otomatis loading & caching)
final departmentListProvider = FutureProvider<List<dynamic>>((ref) async {
  final token = ref.watch(authProvider).token;

  if (token == null) return [];

  final repo = ref.watch(departmentRepositoryProvider);
  try {
    return await repo.getDepartments(token);
  } catch (e) {
    throw Exception(e.toString());
  }
});
