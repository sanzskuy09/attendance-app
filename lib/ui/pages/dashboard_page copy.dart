// ignore_for_file: dead_code, deprecated_member_use
import 'dart:convert';
import 'dart:io';
import 'package:attendance_app/providers/location_provider.dart';
import 'package:attendance_app/shared/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../providers/auth_provider.dart';
import '../../providers/attendance_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'login_page.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int _selectedIndex = 0;

  // Dummy State untuk UI
  // final bool _isInZone = true;
  // final String _checkInTime = "07:45 WIB";
  // final String _checkOutTime = "--:-- WIB";

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null).then((_) => setState(() {}));

    Future.microtask(() {
      ref.read(locationProvider.notifier).getCurrentLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Pantau status loading & error absensi
    final attendanceState = ref.watch(attendanceProvider);

    // final List<Widget> pages = [
    //   _buildHomeTab(context, ref),     // Index 0: Home
    //   _buildHistoryTab(context, ref),  // Index 1: Riwayat
    //   const Center(child: Text("Halaman Akun - Segera Hadir")), // Index 2: Akun
    // ];

    // Listener untuk aksi setelah absensi (Sukses/Gagal)
    ref.listen<AttendanceState>(attendanceProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!, style: whiteTextStyle),
            backgroundColor: errorColor,
          ),
        );
      }

      if (next.isSuccess && (previous == null || !previous.isSuccess)) {
        ScaffoldMessenger.of(context).clearSnackBars();

        // Membedakan pesan sukses berdasarkan tipenya
        String message = next.successType == 'in'
            ? "Absen Masuk Berhasil!"
            : "Absen Pulang Berhasil!";

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message, style: whiteTextStyle),
            backgroundColor: successColor,
          ),
        );

        // Perintah ini akan memaksa Flutter memanggil ulang API getTodayHistory
        ref.invalidate(todayHistoryProvider);

        ref.read(attendanceProvider.notifier).resetSuccess();
      }
    });

    final historyData = ref.watch(todayHistoryProvider).value;
    // Ambil statusnya, default "none" jika belum ada data
    final String currentStatus = historyData?['status'] ?? "none";

    return Scaffold(
      // Menggunakan background dari theme.dart
      backgroundColor: background,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        // Menggunakan primaryColor dari theme.dart
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        // Terapkan font Poppins ke label navigasi
        selectedLabelStyle: primaryTextStyle.copyWith(
          fontSize: 12,
          fontWeight: medium,
        ),
        unselectedLabelStyle: blackTextStyle.copyWith(
          fontSize: 12,
          color: Colors.grey,
        ),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: "Riwayat",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Akun",
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context, ref),
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    _buildLocationCard(ref.watch(locationProvider)),
                    const SizedBox(height: 40),
                    _buildAttendanceButtons(
                      ref.watch(locationProvider),
                      attendanceState,
                      ref,
                      currentStatus,
                    ),
                    const SizedBox(height: 40),
                    _buildHistorySection(ref),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 1. HEADER
  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    String today = DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());

    final authState = ref.watch(authProvider);
    // Beri nilai default jika null (berjaga-jaga)
    final String namaUser = authState.userName ?? "Karyawan";
    final String roleUser = authState.userRole ?? "Staff";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryColor, // Menggunakan primaryColor
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            // <-- HANYA SATU ROW SEKARANG
            children: [
              // 1. Avatar
              CircleAvatar(
                radius: 25,
                backgroundColor: whiteColor,
                child: Icon(
                  Icons.person,
                  color: Colors.grey.shade400,
                  size: 30,
                ),
              ),
              const SizedBox(width: 15),

              // 2. Teks Profil (Aman dibungkus Expanded karena berada di Row utama)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Halo, $namaUser!",
                      style: whiteTextStyle.copyWith(
                        fontSize: 18,
                        fontWeight: bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      roleUser,
                      style: whiteTextStyle.copyWith(
                        fontSize: 14,
                        fontWeight: light,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // 3. Tombol Logout (Otomatis terdorong ke kanan oleh Expanded)
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
              color: blackColor.withOpacity(0.1),
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

  Widget _buildLocationCard(LocationState locState) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: blackColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on, color: primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    "Status Lokasi Anda",
                    style: blackTextStyle.copyWith(
                      fontSize: 16,
                      fontWeight: bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.grey),
                onPressed: () =>
                    ref.read(locationProvider.notifier).getCurrentLocation(),
              ),
            ],
          ),
          const Divider(height: 25),

          if (locState.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (locState.errorMessage != null)
            Text(
              locState.errorMessage!,
              style: blackTextStyle.copyWith(color: errorColor),
            )
          else if (locState.position != null)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: pendingColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.gps_fixed, color: pendingColor),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Koordinat Ditemukan",
                        style: blackTextStyle.copyWith(
                          fontWeight: bold,
                          color: blackColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Lat: ${locState.position!.latitude}",
                        style: blackTextStyle.copyWith(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        "Lng: ${locState.position!.longitude}",
                        style: blackTextStyle.copyWith(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        "Validasi area akan dilakukan saat absen",
                        style: blackTextStyle.copyWith(
                          color: pendingColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            Text(
              "Mencari lokasi...",
              style: blackTextStyle.copyWith(color: Colors.grey),
            ),
        ],
      ),
    );
  }

  // Tambahkan parameter currentStatus
  Widget _buildAttendanceButtons(
    LocationState locState,
    AttendanceState attState,
    WidgetRef ref,
    String currentStatus,
  ) {
    // LOGIKA KUNCI TOMBOL
    bool canClockIn =
        currentStatus == "none" ||
        currentStatus == "" ||
        currentStatus == "not_clocked_in";
    bool canClockOut = currentStatus == "clocked_in";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // TOMBOL ABSEN MASUK
        _singleActionButton(
          title: "ABSEN\nMASUK",
          icon: Icons.login_rounded,
          buttonColor: successColor,
          isClockIn: true,
          isEnabled: canClockIn, // Teruskan status aktif/tidaknya
          locState: locState,
          attState: attState,
          ref: ref,
        ),

        // TOMBOL ABSEN PULANG
        _singleActionButton(
          title: "ABSEN\nPULANG",
          icon: Icons.logout_rounded,
          buttonColor: errorColor,
          isClockIn: false,
          isEnabled: canClockOut, // Teruskan status aktif/tidaknya
          locState: locState,
          attState: attState,
          ref: ref,
        ),
      ],
    );
  }

  // Tambahkan parameter isEnabled
  Widget _singleActionButton({
    required String title,
    required IconData icon,
    required Color buttonColor,
    required bool isClockIn,
    required bool isEnabled,
    required LocationState locState,
    required AttendanceState attState,
    required WidgetRef ref,
  }) {
    final String myType = isClockIn ? 'in' : 'out';
    final bool isMeLoading =
        attState.isLoading && attState.loadingType == myType;

    // Jika tidak enabled, ubah warna menjadi abu-abu
    final Color finalColor = isEnabled ? buttonColor : Colors.grey.shade400;

    return GestureDetector(
      onTap: () async {
        // CEK APAKAH TOMBOL TERKUNCI
        if (!isEnabled) {
          String message = isClockIn
              ? "Anda sudah melakukan absen masuk hari ini."
              : "Anda sudah menyelesaikan absensi hari ini";

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message, style: whiteTextStyle),
              backgroundColor: pendingColor,
            ),
          );
          return;
        }

        if (attState.isLoading) return;

        if (locState.position == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Tunggu sebentar, sedang mencari lokasi...",
                style: whiteTextStyle,
              ),
              backgroundColor: pendingColor,
            ),
          );
          return;
        }

        final token = ref.read(authProvider).token;
        if (token == null) return;

        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: ImageSource.camera,
          preferredCameraDevice: CameraDevice.front,
          imageQuality: 50,
        );

        if (image == null) return;

        final bytes = await File(image.path).readAsBytes();
        final String base64Image = base64Encode(bytes);

        ref
            .read(attendanceProvider.notifier)
            .submitAttendance(
              token: token,
              lat: locState.position!.latitude,
              lng: locState.position!.longitude,
              photoBase64: base64Image,
              isClockIn: isClockIn,
            );
      },
      child: Container(
        height: 150,
        width: 140,
        decoration: BoxDecoration(
          color: finalColor, // Gunakan warna yang sudah difilter
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: finalColor.withOpacity(0.4),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isMeLoading)
              CircularProgressIndicator(color: whiteColor)
            else ...[
              Icon(icon, size: 45, color: whiteColor),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: whiteTextStyle.copyWith(
                  fontSize: 16,
                  fontWeight: bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 4. RIWAYAT HARI INI
  // Tambahkan parameter WidgetRef ref
  Widget _buildHistorySection(WidgetRef ref) {
    // Memantau (watch) data dari API riwayat hari ini
    final historyAsync = ref.watch(todayHistoryProvider);

    // Nilai default
    String checkIn = "--:-- WIB";
    String checkOut = "--:-- WIB";

    // Menangani state Loading, Error, dan Data
    historyAsync.when(
      data: (data) {
        checkIn = data['checkIn']!;
        checkOut = data['checkOut']!;
      },
      loading: () {
        checkIn = "Memuat...";
        checkOut = "Memuat...";
      },
      error: (err, stack) {
        checkIn = "Error";
        checkOut = "Error";
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Riwayat Hari Ini",
          style: blackTextStyle.copyWith(fontSize: 18, fontWeight: bold),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: blackColor.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // JAM MASUK
              Column(
                children: [
                  Icon(Icons.login_rounded, color: successColor, size: 30),
                  const SizedBox(height: 8),
                  Text(
                    "Jam Masuk",
                    style: blackTextStyle.copyWith(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    checkIn,
                    style: blackTextStyle.copyWith(
                      fontWeight: bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Container(height: 50, width: 1, color: Colors.grey.shade300),

              // JAM PULANG
              Column(
                children: [
                  Icon(Icons.logout_rounded, color: errorColor, size: 30),
                  const SizedBox(height: 8),
                  Text(
                    "Jam Pulang",
                    style: blackTextStyle.copyWith(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    checkOut,
                    style: blackTextStyle.copyWith(
                      fontWeight: bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
