import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/employee_provider.dart';
import '../../providers/department_provider.dart';
import '../../providers/office_provider.dart';

class AddEmployeePage extends ConsumerStatefulWidget {
  const AddEmployeePage({super.key});

  @override
  ConsumerState<AddEmployeePage> createState() => _AddEmployeePageState();
}

class _AddEmployeePageState extends ConsumerState<AddEmployeePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers untuk TextField
  final _nikController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  // Variabel untuk Dropdown
  String? _selectedRole;
  int? _selectedDepartmentId;
  int? _selectedOfficeId;
  int? _selectedPositionId = 1; // Dummy default
  int? _selectedShiftId = 1; // Dummy default

  @override
  void dispose() {
    _nikController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitData() async {
    // Validasi Form
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRole == null ||
        _selectedDepartmentId == null ||
        _selectedOfficeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Pastikan Role, Departemen, dan Office sudah dipilih!",
            style: whiteTextStyle,
          ),
          backgroundColor: errorColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final token = ref.read(authProvider).token;
      if (token == null) throw Exception("Sesi habis, silakan login ulang.");

      // Siapkan payload JSON sesuai struktur backend Go Anda
      final payload = {
        "nik": _nikController.text,
        "full_name": _nameController.text,
        "email": _emailController.text,
        "password": _passwordController.text,
        "phone_number": _phoneController.text,
        "role": _selectedRole,
        "department_id": _selectedDepartmentId,
        "office_id": _selectedOfficeId,
        "position_id": _selectedPositionId,
        "shift_id": _selectedShiftId,
        "is_active": true,
      };

      // Panggil fungsi di repository
      await ref.read(employeeRepositoryProvider).createEmployee(token, payload);

      // Refresh data list karyawan agar yang baru langsung muncul
      ref.invalidate(employeeListProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Karyawan berhasil ditambahkan!",
              style: whiteTextStyle,
            ),
            backgroundColor: successColor,
          ),
        );
        Navigator.pop(context); // Kembali ke halaman sebelumnya
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll("Exception: ", ""),
            style: whiteTextStyle,
          ),
          backgroundColor: errorColor,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil data untuk dropdown (Departemen dan Office)
    final deptAsync = ref.watch(departmentListProvider);
    final officeAsync = ref.watch(officeListProvider);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: secondaryColor,
        title: Text(
          "Tambah Karyawan Baru",
          style: whiteTextStyle.copyWith(fontWeight: bold),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: whiteColor),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: secondaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Informasi Dasar",
                      style: blackTextStyle.copyWith(
                        fontSize: 16,
                        fontWeight: bold,
                      ),
                    ),
                    const SizedBox(height: 15),

                    _buildTextField(
                      "NIK",
                      _nikController,
                      Icons.badge_outlined,
                      isNumber: true,
                    ),
                    _buildTextField(
                      "Nama Lengkap",
                      _nameController,
                      Icons.person_outline,
                    ),
                    _buildTextField(
                      "Email",
                      _emailController,
                      Icons.email_outlined,
                      isEmail: true,
                    ),
                    _buildTextField(
                      "Nomor Telepon",
                      _phoneController,
                      Icons.phone_outlined,
                      isNumber: true,
                    ),
                    _buildTextField(
                      "Password Sementara",
                      _passwordController,
                      Icons.lock_outline,
                      isPassword: true,
                    ),

                    const SizedBox(height: 30),
                    Text(
                      "Informasi Penempatan",
                      style: blackTextStyle.copyWith(
                        fontSize: 16,
                        fontWeight: bold,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Dropdown Role
                    _buildDropdown<String>(
                      label: "Role Sistem",
                      icon: Icons.admin_panel_settings_outlined,
                      value: _selectedRole,
                      items: const [
                        DropdownMenuItem(
                          value: "staff",
                          child: Text("Staff / Karyawan"),
                        ),
                        DropdownMenuItem(
                          value: "admin",
                          child: Text("HRD / Admin"),
                        ),
                      ],
                      onChanged: (val) => setState(() => _selectedRole = val),
                    ),

                    // Dropdown Department (Ditarik dari API)
                    deptAsync.when(
                      loading: () => const LinearProgressIndicator(),
                      error: (e, s) => Text(
                        "Gagal memuat departemen",
                        style: blackTextStyle.copyWith(color: errorColor),
                      ),
                      data: (departments) => _buildDropdown<int>(
                        label: "Departemen",
                        icon: Icons.account_tree_outlined,
                        value: _selectedDepartmentId,
                        items: departments.map<DropdownMenuItem<int>>((dept) {
                          return DropdownMenuItem<int>(
                            value: dept['id'],
                            child: Text(dept['name']),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => _selectedDepartmentId = val),
                      ),
                    ),

                    // Dropdown Office (Ditarik dari API)
                    officeAsync.when(
                      loading: () => const LinearProgressIndicator(),
                      error: (e, s) => Text(
                        "Gagal memuat office",
                        style: blackTextStyle.copyWith(color: errorColor),
                      ),
                      data: (offices) => _buildDropdown<int>(
                        label: "Kantor / Toko Penempatan",
                        icon: Icons.store_mall_directory_outlined,
                        value: _selectedOfficeId,
                        items: offices.map<DropdownMenuItem<int>>((office) {
                          return DropdownMenuItem<int>(
                            value: office['id'],
                            child: Text(office['name']),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => _selectedOfficeId = val),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Tombol Simpan
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submitData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(
                          "Simpan Data Karyawan",
                          style: whiteTextStyle.copyWith(
                            fontSize: 16,
                            fontWeight: bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  // Helper Widget untuk TextField yang rapi
  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isPassword = false,
    bool isEmail = false,
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: isNumber
            ? TextInputType.number
            : (isEmail ? TextInputType.emailAddress : TextInputType.text),
        validator: (value) {
          if (value == null || value.isEmpty)
            return '$label tidak boleh kosong';
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: blackTextStyle.copyWith(color: Colors.grey),
          prefixIcon: Icon(icon, color: secondaryColor),
          filled: true,
          fillColor: whiteColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: secondaryColor, width: 2),
          ),
        ),
      ),
    );
  }

  // Helper Widget untuk Dropdown
  Widget _buildDropdown<T>({
    required String label,
    required IconData icon,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: blackTextStyle.copyWith(color: Colors.grey),
          prefixIcon: Icon(icon, color: secondaryColor),
          filled: true,
          fillColor: whiteColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: secondaryColor, width: 2),
          ),
        ),
      ),
    );
  }
}
