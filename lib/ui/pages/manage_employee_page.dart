import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/theme.dart';
import '../../providers/employee_provider.dart';

class ManageEmployeePage extends ConsumerWidget {
  const ManageEmployeePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Memantau data dari API
    final employeeAsync = ref.watch(employeeListProvider);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor:
            secondaryColor, // Menggunakan warna biru corporate/admin
        elevation: 0,
        title: Text(
          "Data Karyawan",
          style: whiteTextStyle.copyWith(fontWeight: bold),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: whiteColor),
      ),

      // Tombol Tambah Karyawan (Mengambang di kanan bawah)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigasi ke halaman Form Tambah Karyawan
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Membuka form tambah karyawan...")),
          );
        },
        backgroundColor: primaryColor,
        child: Icon(Icons.person_add_alt_1_rounded, color: whiteColor),
      ),

      body: employeeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text("Error: $err", style: blackTextStyle)),
        data: (List<dynamic> employees) {
          if (employees.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.group_off_rounded,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Belum ada data karyawan",
                    style: blackTextStyle.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(employeeListProvider),
            color: secondaryColor,
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: employees.length,
              separatorBuilder: (context, index) => const SizedBox(height: 15),
              itemBuilder: (context, index) {
                final emp = employees[index];

                // Ambil data dari JSON (Sesuaikan dengan key dari backend Go Anda)
                final String name = emp['full_name'] ?? 'Tanpa Nama';
                final String role = emp['role'] ?? 'Staff';
                final String nik = emp['nik'] ?? '-';
                // Jika department berupa object: emp['department']['name']
                final String dept = emp['department']?['name'] ?? 'General';

                return Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: blackColor.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Avatar Inisial Nama
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: secondaryColor.withOpacity(0.1),
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: primaryTextStyle.copyWith(
                            fontSize: 20,
                            fontWeight: bold,
                            color: secondaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),

                      // Info Karyawan
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: blackTextStyle.copyWith(
                                fontSize: 16,
                                fontWeight: bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "NIK: $nik",
                              style: blackTextStyle.copyWith(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                "$dept • $role",
                                style: blackTextStyle.copyWith(
                                  fontSize: 11,
                                  fontWeight: medium,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Tombol Aksi (Edit / Hapus)
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert_rounded,
                          color: Colors.grey,
                        ),
                        onSelected: (value) {
                          if (value == 'edit') {
                            // TODO: Navigasi ke Edit
                          } else if (value == 'delete') {
                            // TODO: Panggil fungsi delete di repository
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text("Edit", style: blackTextStyle),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: errorColor, size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  "Hapus",
                                  style: blackTextStyle.copyWith(
                                    color: errorColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
