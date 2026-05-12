import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/employee_provider.dart';
import '../../providers/department_provider.dart';
import '../../providers/office_provider.dart';

class EditEmployeePage extends ConsumerStatefulWidget {
  final Map<String, dynamic>
  employeeData; // Menerima data karyawan yang akan diedit

  const EditEmployeePage({super.key, required this.employeeData});

  @override
  ConsumerState<EditEmployeePage> createState() => _EditEmployeePageState();
}

class _EditEmployeePageState extends ConsumerState<EditEmployeePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late TextEditingController _nikController;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  final _passwordController =
      TextEditingController(); // Dikosongkan jika tidak ingin ganti password

  String? _selectedRole;
  int? _selectedDepartmentId;
  int? _selectedOfficeId;
  int? _selectedPositionId;
  int? _selectedShiftId;

  @override
  void initState() {
    super.initState();
    // Mengisi form dengan data lama
    _nikController = TextEditingController(
      text: widget.employeeData['nik']?.toString() ?? '',
    );
    _nameController = TextEditingController(
      text: widget.employeeData['full_name'] ?? '',
    );
    _emailController = TextEditingController(
      text: widget.employeeData['email'] ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.employeeData['phone_number'] ?? '',
    );

    _selectedRole = widget.employeeData['role'];
    _selectedDepartmentId = widget.employeeData['department_id'];
    _selectedOfficeId = widget.employeeData['office_id'];
    _selectedPositionId = widget.employeeData['position_id'] ?? 1;
    _selectedShiftId = widget.employeeData['shift_id'] ?? 1;
  }

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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final token = ref.read(authProvider).token;
      if (token == null) throw Exception("Sesi habis.");

      final payload = {
        "nik": _nikController.text,
        "full_name": _nameController.text,
        "email": _emailController.text,
        "phone_number": _phoneController.text,
        "role": _selectedRole,
        "department_id": _selectedDepartmentId,
        "office_id": _selectedOfficeId,
        "position_id": _selectedPositionId,
        "shift_id": _selectedShiftId,
        "is_active": true,
      };

      // Jika password diisi, baru kita kirim ke backend untuk diupdate
      if (_passwordController.text.isNotEmpty) {
        payload["password"] = _passwordController.text;
      }

      final int empId = widget.employeeData['id'];
      await ref
          .read(employeeRepositoryProvider)
          .updateEmployee(token, empId, payload);
      ref.invalidate(employeeListProvider); // Refresh list karyawan

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Data karyawan berhasil diperbarui!",
              style: whiteTextStyle,
            ),
            backgroundColor: successColor,
          ),
        );
        Navigator.pop(context);
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
    final deptAsync = ref.watch(departmentListProvider);
    final officeAsync = ref.watch(officeListProvider);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: secondaryColor,
        title: Text(
          "Edit Karyawan",
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
                    ),
                    _buildTextField(
                      "Nomor Telepon",
                      _phoneController,
                      Icons.phone_outlined,
                    ),

                    // Password opsional untuk Edit
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText:
                              "Password Baru (Kosongkan jika tidak diubah)",
                          labelStyle: blackTextStyle.copyWith(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: secondaryColor,
                          ),
                          filled: true,
                          fillColor: whiteColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    Text(
                      "Informasi Penempatan",
                      style: blackTextStyle.copyWith(
                        fontSize: 16,
                        fontWeight: bold,
                      ),
                    ),
                    const SizedBox(height: 15),

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
                          value: "hrd",
                          child: Text("HRD / Admin"),
                        ),
                      ],
                      onChanged: (val) => setState(() => _selectedRole = val),
                    ),

                    deptAsync.when(
                      loading: () => const LinearProgressIndicator(),
                      error: (e, s) => const SizedBox(),
                      data: (departments) => _buildDropdown<int>(
                        label: "Departemen",
                        icon: Icons.account_tree_outlined,
                        value: _selectedDepartmentId,
                        items: departments
                            .map<DropdownMenuItem<int>>(
                              (dept) => DropdownMenuItem(
                                value: dept['id'],
                                child: Text(dept['name']),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedDepartmentId = val),
                      ),
                    ),

                    officeAsync.when(
                      loading: () => const LinearProgressIndicator(),
                      error: (e, s) => const SizedBox(),
                      data: (offices) => _buildDropdown<int>(
                        label: "Kantor / Toko Penempatan",
                        icon: Icons.store_mall_directory_outlined,
                        value: _selectedOfficeId,
                        items: offices
                            .map<DropdownMenuItem<int>>(
                              (office) => DropdownMenuItem(
                                value: office['id'],
                                child: Text(office['name']),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedOfficeId = val),
                      ),
                    ),

                    const SizedBox(height: 40),
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
                          "Perbarui Data",
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

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        validator: (value) => (value == null || value.isEmpty)
            ? '$label tidak boleh kosong'
            : null,
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
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required IconData icon,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    // Memastikan value yang ada di API benar-benar ada di dalam daftar items Dropdown
    T? safeValue = items.any((item) => item.value == value) ? value : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<T>(
        value: safeValue,
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
        ),
      ),
    );
  }
}
