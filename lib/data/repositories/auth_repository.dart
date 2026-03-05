class AuthRepository {
  Future<Map<String, dynamic>> login(String nik, String password) async {
    await Future.delayed(const Duration(seconds: 2));

    print('NIK: $nik, Password: $password');

    if (nik == '12345' && password == '12345') {
      return {'status': true, 'token': 'iaugdikjh9hrw8fg', 'username': 'IHSAN'};
    } else {
      throw Exception('NIK atau Password Salah');
    }
  }
}
