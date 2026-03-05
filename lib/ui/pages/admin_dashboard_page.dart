import 'package:attendance_app/ui/pages/manage_department_page.dart';
import 'package:attendance_app/ui/pages/manage_employee_page.dart';
import 'package:attendance_app/ui/pages/manage_office_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
// Sesuaikan import ini dengan struktur folder Anda
import '../../shared/theme.dart';
import '../../providers/auth_provider.dart';
import 'login_page.dart';

class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomeTab(context, ref), // Index 0: Dashboard/Home
      _buildReportTab(context, ref), // Index 1: Laporan
      const Center(
        child: Text("Pengaturan - Segera Hadir"),
      ), // Index 2: Pengaturan
    ];

    return Scaffold(
      backgroundColor: background,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: primaryTextStyle.copyWith(
          fontSize: 12,
          fontWeight: medium,
        ),
        unselectedLabelStyle: blackTextStyle.copyWith(
          fontSize: 12,
          color: Colors.grey,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.print_rounded),
            label: "Laporan",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Pengaturan",
          ),
        ],
      ),

      // Tampilkan halaman berdasarkan index
      body: SafeArea(child: pages[_selectedIndex]),
    );
  }

  // ==========================================
  // TAB 1: HOME (Dashboard Admin)
  // ==========================================
  Widget _buildHomeTab(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(context, ref),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCards(),
                const SizedBox(height: 30),
                _buildQuickMenu(), // (Berisi Data Karyawan, Dept, Office)
                const SizedBox(height: 30),
                _buildLiveLog(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: LAPORAN (Pusat Cetak Data)
  // ==========================================
  Widget _buildReportTab(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Tab Laporan
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: secondaryColor), // Pakai biru admin
          child: Text(
            "Pusat Laporan",
            style: whiteTextStyle.copyWith(fontSize: 20, fontWeight: bold),
          ),
        ),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                "Master Data",
                style: blackTextStyle.copyWith(fontSize: 16, fontWeight: bold),
              ),
              const SizedBox(height: 15),

              // 1. Laporan Karyawan
              _reportCardItem(
                title: "Data Karyawan",
                subtitle: "Ekspor seluruh data profil karyawan",
                icon: Icons.people_alt_rounded,
                color: primaryColor,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Mengunduh Laporan Karyawan..."),
                    ),
                  );
                },
              ),
              const SizedBox(height: 15),

              // 2. Laporan Department
              _reportCardItem(
                title: "Data Department",
                subtitle: "Ekspor struktur departemen perusahaan",
                icon: Icons.account_tree_rounded,
                color: secondaryColor,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Mengunduh Laporan Department..."),
                    ),
                  );
                },
              ),
              const SizedBox(height: 15),

              // 3. Laporan Office
              _reportCardItem(
                title: "Data Office / Toko",
                subtitle: "Ekspor data cabang & status geofencing",
                icon: Icons.store_mall_directory_rounded,
                color: successColor,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Mengunduh Laporan Office..."),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),
              Text(
                "Data Operasional",
                style: blackTextStyle.copyWith(fontSize: 16, fontWeight: bold),
              ),
              const SizedBox(height: 15),

              // 4. Laporan Absensi
              _reportCardItem(
                title: "Riwayat Absensi",
                subtitle: "Cetak laporan jam masuk & pulang (Filter Tanggal)",
                icon: Icons.history_rounded,
                color: pendingColor, // Pakai warna orange/kuning
                onTap: () {
                  // Khusus absensi, biasanya butuh popup untuk pilih rentang tanggal
                  _showDateRangePicker(context);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper Widget untuk Kartu Menu Laporan
  Widget _reportCardItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: blackTextStyle.copyWith(
                          fontSize: 16,
                          fontWeight: bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: blackTextStyle.copyWith(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.download_rounded, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper fungsi untuk memunculkan Bottom Sheet (Pilih Tanggal Laporan Absensi)
  void _showDateRangePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Cetak Laporan Absensi",
                style: blackTextStyle.copyWith(fontSize: 18, fontWeight: bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.today_rounded, color: secondaryColor),
                title: Text(
                  "Hari Ini",
                  style: blackTextStyle.copyWith(fontWeight: medium),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Mencetak laporan hari ini..."),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.date_range_rounded, color: secondaryColor),
                title: Text(
                  "Bulan Ini",
                  style: blackTextStyle.copyWith(fontWeight: medium),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Mencetak laporan bulan ini..."),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.edit_calendar_rounded,
                  color: secondaryColor,
                ),
                title: Text(
                  "Pilih Rentang Tanggal",
                  style: blackTextStyle.copyWith(fontWeight: medium),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Buka DateRangePicker bawaan Flutter
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 1. HEADER (Mirip dengan User, tapi warna beda/tulisan beda)
  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    String today = DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());
    final authState = ref.watch(authProvider);
    final String namaAdmin = authState.userName ?? "Admin";
    final String roleAdmin = authState.userRole ?? "HR Manager";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:
            secondaryColor, // Kita pakai warna Biru (Corporate Blue) agar membedakan dengan akun Staff
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: whiteColor,
                child: Icon(
                  Icons.admin_panel_settings,
                  color: secondaryColor,
                  size: 30,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Halo, $namaAdmin!",
                      style: whiteTextStyle.copyWith(
                        fontSize: 18,
                        fontWeight: bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      roleAdmin.toUpperCase(),
                      style: whiteTextStyle.copyWith(
                        fontSize: 12,
                        fontWeight: medium,
                        letterSpacing: 1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.logout, color: whiteColor),
                onPressed: () {
                  ref.read(authProvider.notifier).logout();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: blackColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_today, color: whiteColor, size: 16),
                const SizedBox(width: 8),
                Text(
                  today,
                  style: whiteTextStyle.copyWith(
                    fontSize: 14,
                    fontWeight: medium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. RINGKASAN ABSENSI HARI INI
  Widget _buildSummaryCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Ringkasan Kehadiran",
          style: blackTextStyle.copyWith(fontSize: 18, fontWeight: bold),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _summaryBox(
                "Hadir",
                "45",
                successColor,
                Icons.check_circle,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _summaryBox(
                "Terlambat",
                "5",
                pendingColor,
                Icons.timer_off,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _summaryBox("Absen", "2", errorColor, Icons.cancel),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _summaryBox("Izin/Sakit", "1", Colors.blue, Icons.sick),
            ),
          ],
        ),
      ],
    );
  }

  Widget _summaryBox(String title, String count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: blackColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 28),
              Text(
                count,
                style: blackTextStyle.copyWith(
                  fontSize: 24,
                  fontWeight: bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: blackTextStyle.copyWith(
              fontSize: 14,
              color: Colors.grey.shade700,
              fontWeight: medium,
            ),
          ),
        ],
      ),
    );
  }

  // 3. MENU CEPAT (Termasuk Geofencing)
  // 3. MENU CEPAT (Karyawan, Departemen, Office)
  Widget _buildQuickMenu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Menu Cepat",
          style: blackTextStyle.copyWith(fontSize: 18, fontWeight: bold),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // MENU 1: DATA KARYAWAN
            Expanded(
              child: _menuActionItem(
                icon: Icons.people_alt,
                label: "Data\nKaryawan",
                color: primaryColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ManageEmployeePage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 10), // Jarak antar kotak
            // MENU 2: DATA DEPARTMENT
            Expanded(
              child: _menuActionItem(
                icon: Icons.account_tree_rounded, // Icon struktur organisasi
                label: "Data\nDepartment",
                color: secondaryColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ManageDepartmentPage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),

            // MENU 3: DATA OFFICE (Tempat Atur Poligon Ray Casting)
            Expanded(
              child: _menuActionItem(
                icon: Icons.store_mall_directory_rounded, // Icon toko/kantor
                label: "Data\nOffice",
                color: successColor, // Pakai warna hijau
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ManageOfficePage()),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper Widget Menu Action Item (Sedikit dimodifikasi agar teks tidak overflow)
  Widget _menuActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: blackColor.withOpacity(0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: blackTextStyle.copyWith(fontSize: 11, fontWeight: bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // 4. LIVE LOG ABSENSI
  Widget _buildLiveLog() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Aktivitas Terkini",
              style: blackTextStyle.copyWith(fontSize: 18, fontWeight: bold),
            ),
            Text(
              "Lihat Semua",
              style: primaryTextStyle.copyWith(
                fontSize: 12,
                fontWeight: medium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Container(
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(), // Scroll dimatikan agar gabung dengan halaman
            itemCount: 3, // Mockup 3 data
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              // Dummy data
              List<Map<String, dynamic>> logs = [
                {
                  "name": "Andi (Kasir)",
                  "status": "Masuk",
                  "time": "07:30 WIB",
                  "color": successColor,
                },
                {
                  "name": "Rina (Sales)",
                  "status": "Terlambat",
                  "time": "08:15 WIB",
                  "color": pendingColor,
                },
                {
                  "name": "Doni (Gudang)",
                  "status": "Pulang",
                  "time": "17:05 WIB",
                  "color": secondaryColor,
                },
              ];

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: logs[index]['color'].withOpacity(0.1),
                  child: Icon(
                    Icons.history,
                    color: logs[index]['color'],
                    size: 20,
                  ),
                ),
                title: Text(
                  logs[index]['name'],
                  style: blackTextStyle.copyWith(
                    fontSize: 14,
                    fontWeight: bold,
                  ),
                ),
                subtitle: Text(
                  logs[index]['status'],
                  style: blackTextStyle.copyWith(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                trailing: Text(
                  logs[index]['time'],
                  style: blackTextStyle.copyWith(
                    fontSize: 12,
                    fontWeight: medium,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
