import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/office_provider.dart';

class EditOfficePage extends ConsumerStatefulWidget {
  final Map<String, dynamic> data;
  const EditOfficePage({super.key, required this.data});

  @override
  ConsumerState<EditOfficePage> createState() => _EditOfficePageState();
}

class _EditOfficePageState extends ConsumerState<EditOfficePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.data['name']);
    _addressController = TextEditingController(text: widget.data['address']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final token = ref.read(authProvider).token;
      await ref.read(officeRepositoryProvider).updateOffice(
        token!,
        widget.data['id'],
        {"name": _nameController.text, "address": _addressController.text},
      );

      ref.invalidate(officeListProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Data office berhasil diperbarui!",
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
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: successColor,
        elevation: 0,
        title: Text(
          "Edit Office / Toko",
          style: whiteTextStyle.copyWith(fontWeight: bold),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: whiteColor),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: successColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Edit Informasi Lokasi",
                      style: blackTextStyle.copyWith(
                        fontSize: 16,
                        fontWeight: bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildTextField(
                      "Nama Kantor / Toko",
                      _nameController,
                      Icons.store_mall_directory_outlined,
                    ),
                    _buildTextField(
                      "Alamat Lengkap",
                      _addressController,
                      Icons.location_on_outlined,
                      maxLines: 3,
                    ),

                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: successColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(
                          "Perbarui Data Office",
                          style: whiteTextStyle.copyWith(
                            fontSize: 16,
                            fontWeight: bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: (value) => (value == null || value.isEmpty)
            ? '$label tidak boleh kosong'
            : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: blackTextStyle.copyWith(color: Colors.grey),
          prefixIcon: Icon(icon, color: successColor),
          filled: true,
          fillColor: whiteColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: successColor, width: 2),
          ),
        ),
      ),
    );
  }
}
