import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/theme.dart';
import '../../providers/office_provider.dart';

class ManageOfficePage extends ConsumerWidget {
  const ManageOfficePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final officeAsync = ref.watch(officeListProvider);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor:
            successColor, // Menggunakan hijau agar senada dengan menu cepat
        elevation: 0,
        title: Text(
          "Data Office / Toko",
          style: whiteTextStyle.copyWith(fontWeight: bold),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: whiteColor),
      ),

      // Tombol Tambah Office
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Membuka form tambah office...")),
          );
        },
        backgroundColor: successColor,
        child: Icon(Icons.add_business_rounded, color: whiteColor),
      ),

      body: officeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text("Error: $err", style: blackTextStyle)),
        data: (List<dynamic> offices) {
          if (offices.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.storefront_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Belum ada data office",
                    style: blackTextStyle.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(officeListProvider),
            color: successColor,
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: offices.length,
              separatorBuilder: (context, index) => const SizedBox(height: 15),
              itemBuilder: (context, index) {
                final office = offices[index];

                // Ambil data dari JSON
                final String name =
                    office['name'] ?? 'Nama Office Tidak Diketahui';
                final String address =
                    office['address'] ?? 'Alamat belum diatur';

                // Simulasi pengecekan apakah poligon sudah diisi (asumsi dari backend)
                // Misalnya backend mengirim array 'polygon'
                final bool hasPolygon =
                    office['polygon'] != null &&
                    (office['polygon'] as List).isNotEmpty;

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
                      // Icon Office
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: successColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.store_mall_directory_rounded,
                          color: successColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 15),

                      // Info Office
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
                              address,
                              style: blackTextStyle.copyWith(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),

                            // Indikator Poligon (Fokus Skripsi)
                            Row(
                              children: [
                                Icon(
                                  hasPolygon
                                      ? Icons.map_rounded
                                      : Icons.map_outlined,
                                  size: 14,
                                  color: hasPolygon
                                      ? primaryColor
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  hasPolygon
                                      ? "Area Geofence Aktif"
                                      : "Geofence Belum Diatur",
                                  style: blackTextStyle.copyWith(
                                    fontSize: 11,
                                    fontWeight: bold,
                                    color: hasPolygon
                                        ? primaryColor
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Tombol Set Poligon / Aksi
                      IconButton(
                        icon: Icon(
                          Icons.settings_overscan_rounded,
                          color: primaryColor,
                        ),
                        tooltip: "Atur Geofence",
                        onPressed: () {
                          // TODO: Buka halaman Peta untuk menggambar poligon
                        },
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
