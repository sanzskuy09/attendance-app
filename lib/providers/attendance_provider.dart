import 'package:attendance_app/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:attendance_app/data/repositories/attendance_repository.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

class AttendanceState {
  final bool isLoading;
  final String? loadingType; // 'in' atau 'out'
  final String? errorMessage;
  final bool isSuccess;
  final String? successType; // 'in' atau 'out'

  AttendanceState({
    this.isLoading = false,
    this.loadingType,
    this.errorMessage,
    this.isSuccess = false,
    this.successType,
  });

  AttendanceState copyWith({
    bool? isLoading,
    String? loadingType,
    String? errorMessage,
    bool? isSuccess,
    String? successType,
  }) {
    return AttendanceState(
      isLoading: isLoading ?? this.isLoading,
      loadingType: loadingType, // Bisa di-null-kan
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
      successType: successType, // Bisa di-null-kan
    );
  }
}

class AttendanceNotifier extends StateNotifier<AttendanceState> {
  final AttendanceRepository _repository;

  AttendanceNotifier(this._repository) : super(AttendanceState());

  Future<void> submitAttendance({
    required String token,
    required double lat,
    required double lng,
    required String photoBase64,
    required bool isClockIn, // Penanda Masuk atau Pulang
  }) async {
    final type = isClockIn ? 'in' : 'out';
    state = state.copyWith(
      isLoading: true,
      loadingType: type,
      errorMessage: null,
      isSuccess: false,
    );

    try {
      if (isClockIn) {
        await _repository.clockIn(
          token: token,
          latitude: lat,
          longitude: lng,
          photoBase64: photoBase64,
        );
      } else {
        await _repository.clockOut(
          token: token,
          latitude: lat,
          longitude: lng,
          photoBase64: photoBase64,
        );
      }

      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        successType: type,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void resetSuccess() {
    if (state.isSuccess) {
      state = state.copyWith(isSuccess: false, successType: null);
    }
  }
}

final attendanceRepositoryProvider = Provider((ref) => AttendanceRepository());
final attendanceProvider =
    StateNotifierProvider<AttendanceNotifier, AttendanceState>((ref) {
      final repo = ref.watch(attendanceRepositoryProvider);
      return AttendanceNotifier(repo);
    });

// Provider khusus untuk mengambil riwayat hari ini
// Ubah tipe datanya menjadi <Map<String, dynamic>>
final todayHistoryProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final token = ref.watch(authProvider).token;

  // Jika belum login
  if (token == null) {
    return {"checkIn": "--:-- WIB", "checkOut": "--:-- WIB", "status": "none"};
  }

  final repo = ref.watch(attendanceRepositoryProvider);
  try {
    final result = await repo.getTodayHistory(token);
    final data = result['data'];

    // Ambil status dari JSON root. Jika null, anggap "none"
    final String status = result['status'] ?? "none";

    if (data == null) {
      return {
        "checkIn": "--:-- WIB",
        "checkOut": "--:-- WIB",
        "status": status,
      };
    }

    String checkIn = "--:-- WIB";
    String checkOut = "--:-- WIB";

    if (data['clock_in_time'] != null) {
      DateTime inDateTime = DateTime.parse(data['clock_in_time']).toLocal();
      checkIn = "${DateFormat('HH:mm').format(inDateTime)} WIB";
    }

    if (data['clock_out_time'] != null) {
      DateTime outDateTime = DateTime.parse(data['clock_out_time']).toLocal();
      checkOut = "${DateFormat('HH:mm').format(outDateTime)} WIB";
    }

    return {
      "checkIn": checkIn,
      "checkOut": checkOut,
      "status": status, // Kirim status ke UI
    };
  } catch (e) {
    return {"checkIn": "--:-- WIB", "checkOut": "--:-- WIB", "status": "none"};
  }
});

// Provider khusus untuk mengambil seluruh daftar riwayat absensi
final historyListProvider = FutureProvider<List<dynamic>>((ref) async {
  final token = ref.watch(authProvider).token;

  if (token == null) return [];

  final repo = ref.watch(attendanceRepositoryProvider);
  try {
    final result = await repo.getAttendanceHistory(token);
    return result;
  } catch (e) {
    throw Exception(e.toString());
  }
});
