import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:geolocator/geolocator.dart';

// 1. Class State untuk menyimpan data lokasi
class LocationState {
  final bool isLoading;
  final Position? position;
  final String? errorMessage;

  LocationState({this.isLoading = false, this.position, this.errorMessage});

  LocationState copyWith({
    bool? isLoading,
    Position? position,
    String? errorMessage,
  }) {
    return LocationState(
      isLoading: isLoading ?? this.isLoading,
      position: position ?? this.position,
      errorMessage: errorMessage,
    );
  }
}

// 2. Notifier untuk logic Geolocation
class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier() : super(LocationState());

  Future<void> getCurrentLocation() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      bool serviceEnabled;
      LocationPermission permission;

      // Cek apakah GPS menyala
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('GPS tidak aktif. Mohon nyalakan GPS Anda.');
      }

      // Cek izin aplikasi
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Izin lokasi ditolak.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Izin lokasi ditolak permanen. Buka pengaturan HP.');
      }

      // Ambil posisi akurat
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy:
            LocationAccuracy.high, // Akurasi tinggi penting untuk Geofencing
      );

      state = state.copyWith(
        isLoading: false,
        position: position,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }
}

// 3. Daftarkan Provider
final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>(
  (ref) {
    return LocationNotifier();
  },
);
