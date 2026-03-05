// 1. STATE (Model untuk menampung data state)
import 'package:attendance_app/data/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final String? token;
  final bool isAuthenticated;

  AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.token,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? token,
    bool? isAuthenticated,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      token: token ?? this.token,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

// 2. NOTIFIER (Controller yang mengubah state)
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(AuthState());

  Future<void> login(String nik, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _repository.login(nik, password);

      state = state.copyWith(
        isLoading: false,
        errorMessage: null,
        token: result['token'],
        isAuthenticated: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void logout() {
    // Mereset state kembali ke kondisi awal (kosong/tidak login)
    state = AuthState();
  }
}

// 3. PROVIDER DEFINITION (Dependency Injection)
final authRepositoryProvider = Provider((ref) => AuthRepository());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo);
});
