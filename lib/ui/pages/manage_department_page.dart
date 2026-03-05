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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Membuka form tambah departemen...")),
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
