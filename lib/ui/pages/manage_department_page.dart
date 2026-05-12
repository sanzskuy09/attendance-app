import 'package:attendance_app/providers/auth_provider.dart';
import 'package:attendance_app/ui/pages/add_department_page.dart';
import 'package:attendance_app/ui/pages/edit_department_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/theme.dart';
import '../../providers/department_provider.dart';

class ManageDepartmentPage extends ConsumerWidget {
  const ManageDepartmentPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final departmentAsync = ref.watch(departmentListProvider);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: secondaryColor,
        elevation: 0,
        title: Text(
          "Data Department",
          style: whiteTextStyle.copyWith(fontWeight: bold),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: whiteColor),
      ),

      // Tombol Tambah Department
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddDepartmentPage()),
          );
        },
        backgroundColor: secondaryColor,
        child: Icon(Icons.add_rounded, color: whiteColor, size: 30),
      ),

      body: departmentAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text("Error: $err", style: blackTextStyle)),
        data: (List<dynamic> departments) {
          if (departments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_tree_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Belum ada data departemen",
                    style: blackTextStyle.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(departmentListProvider),
            color: secondaryColor,
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: departments.length,
              separatorBuilder: (context, index) => const SizedBox(height: 15),
              itemBuilder: (context, index) {
                final dept = departments[index];

                // Ambil data dari JSON
                final String name = dept['name'] ?? 'Nama Department';
                final String desc =
                    dept['description'] ?? 'Tidak ada deskripsi';

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
                      // Icon Department
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: secondaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.account_tree_rounded,
                          color: secondaryColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 15),

                      // Info Department
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
                              desc,
                              style: blackTextStyle.copyWith(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Menu Aksi
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert_rounded,
                          color: Colors.grey,
                        ),
                        onSelected: (value) async {
                          if (value == 'edit') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditDepartmentPage(data: dept),
                              ),
                            );
                          } else if (value == 'delete') {
                            // Tambahkan dialog konfirmasi sebelum menghapus
                            bool confirmDelete =
                                await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(
                                      "Hapus Karyawan?",
                                      style: blackTextStyle.copyWith(
                                        fontWeight: bold,
                                      ),
                                    ),
                                    content: Text(
                                      "Apakah Anda yakin ingin menghapus data department ${name}? Aksi ini tidak dapat dibatalkan.",
                                      style: blackTextStyle,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: Text(
                                          "Batal",
                                          style: blackTextStyle.copyWith(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: errorColor,
                                        ),
                                        child: Text(
                                          "Hapus",
                                          style: whiteTextStyle,
                                        ),
                                      ),
                                    ],
                                  ),
                                ) ??
                                false;

                            if (confirmDelete) {
                              final token = ref.read(authProvider).token;
                              await ref
                                  .read(departmentRepositoryProvider)
                                  .deleteDepartment(token!, dept['id']);
                              ref.invalidate(departmentListProvider);
                            }
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
