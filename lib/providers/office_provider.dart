import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/office_repository.dart';
import 'auth_provider.dart';

final officeRepositoryProvider = Provider((ref) => OfficeRepository());

// Provider untuk mengambil daftar office (Otomatis loading & caching)
final officeListProvider = FutureProvider<List<dynamic>>((ref) async {
  final token = ref.watch(authProvider).token;

  if (token == null) return [];

  final repo = ref.watch(officeRepositoryProvider);
  try {
    return await repo.getOffices(token);
  } catch (e) {
    throw Exception(e.toString());
  }
});
