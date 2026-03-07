import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/date_symbol_data_local.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

class PdfReportService {
  // ==========================================
  // HELPER UNTUK MEMUAT GAMBAR LOGO
  // ==========================================
  static Future<pw.ImageProvider> _loadLogoImage() async {
    // Memuat gambar logo dari assets sebagai bytes
    final ByteData logoData = await rootBundle.load('assets/logo.png');
    final Uint8List logoBytes = logoData.buffer.asUint8List();

    // Mengubah bytes menjadi pw.ImageProvider yang bisa dimengerti oleh pdf package
    return pw.MemoryImage(logoBytes);
  }

  // Fungsi untuk membuat PDF Data Department
  static Future<Uint8List> generateDepartmentReport(
    List<dynamic> departments,
  ) async {
    final pdf = pw.Document();
    initializeDateFormatting('id_ID', null);

    final pw.ImageProvider logoImage = await _loadLogoImage();

    final String currentDate = DateFormat(
      'EEEE, d MMMM yyyy',
      'id_ID',
    ).format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            _buildHeader(logoImage),
            pw.SizedBox(height: 20),
            _buildTitle("LAPORAN DATA DEPARTMENT"),
            pw.SizedBox(height: 20),
            _buildDepartmentTable(departments),
            pw.SizedBox(height: 40),
            _buildSignatureBlock(currentDate),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // ==========================================
  // LAPORAN DATA KARYAWAN
  // ==========================================
  static Future<Uint8List> generateEmployeeReport(
    List<dynamic> employees,
  ) async {
    final pdf = pw.Document();
    initializeDateFormatting('id_ID', null); // Inisialisasi locale

    final pw.ImageProvider logoImage = await _loadLogoImage();

    final String currentDate = DateFormat(
      'EEEE, d MMMM yyyy',
      'id_ID',
    ).format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            _buildHeader(logoImage), // Menggunakan kop surat yang sama
            pw.SizedBox(height: 20),
            _buildTitle("LAPORAN DATA KARYAWAN"),
            pw.SizedBox(height: 20),
            _buildEmployeeTable(employees), // Memanggil tabel khusus karyawan
            pw.SizedBox(height: 40),
            _buildSignatureBlock(currentDate), // Menggunakan ttd yang sama
          ];
        },
      ),
    );

    return pdf.save();
  }

  // ==========================================
  // LAPORAN DATA KANTOR / OFFICE
  // ==========================================
  static Future<Uint8List> generateOfficeReport(List<dynamic> offices) async {
    final pdf = pw.Document();

    // Inisialisasi locale dan muat logo
    initializeDateFormatting('id_ID', null);
    final pw.ImageProvider logoImage = await _loadLogoImage();
    final String currentDate = DateFormat(
      'EEEE, d MMMM yyyy',
      'id_ID',
    ).format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            _buildHeader(logoImage),
            pw.SizedBox(height: 20),
            // Judul sesuai mockup Anda
            _buildTitle("LAPORAN DATA KANTOR LOKASI (OFFICE)"),
            pw.SizedBox(height: 20),
            _buildOfficeTable(offices), // Panggil tabel office
            pw.SizedBox(height: 40),
            _buildSignatureBlock(currentDate),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // ==========================================
  // LAPORAN ABSENSI KARYAWAN
  // ==========================================
  static Future<Uint8List> generateAttendanceReport(
    List<dynamic> attendances,
    String period,
  ) async {
    final pdf = pw.Document();

    initializeDateFormatting('id_ID', null);
    final pw.ImageProvider logoImage = await _loadLogoImage();
    final String currentDate = DateFormat(
      'EEEE, d MMMM yyyy',
      'id_ID',
    ).format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat
            .a4
            .landscape, // Gunakan Landscape karena kolomnya banyak
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            _buildHeader(logoImage),
            pw.SizedBox(height: 20),
            _buildTitle("LAPORAN ABSENSI KARYAWAN"),
            pw.SizedBox(height: 5),
            pw.Center(
              child: pw.Text(
                "Periode: $period",
                style: const pw.TextStyle(fontSize: 10),
              ),
            ),
            pw.SizedBox(height: 20),
            _buildAttendanceTable(attendances),
            pw.SizedBox(height: 40),
            _buildSignatureBlock(currentDate),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // ==========================================
  // WIDGET COMPONENTS UNTUK PDF
  // ==========================================
  // 1. KOP SURAT (Sesuai Mockup)
  static pw.Widget _buildHeader(pw.ImageProvider logoImage) {
    return pw.Column(
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            // Placeholder Logo (Kotak Kiri)
            // pw.Container(
            //   width: 60,
            //   height: 60,
            //   decoration: pw.BoxDecoration(border: pw.Border.all(width: 1)),
            //   child: pw.Center(
            //     child: pw.Text(
            //       "LOGO",
            //       style: pw.TextStyle(
            //         fontWeight: pw.FontWeight.bold,
            //         fontSize: 12,
            //       ),
            //     ),
            //   ),
            // ),
            pw.Container(
              width: 80, // Sesuaikan lebar logo agar pas di kop
              height: 80, // Sesuaikan tinggi logo
              child: pw.Center(
                child: pw.Image(
                  logoImage,
                  fit: pw.BoxFit.contain,
                ), // Tampilkan gambar PNG
              ),
            ),
            pw.SizedBox(width: 20),
            // Info Perusahaan (Tengah)
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    "PT. TRANSRETAIL INDONESIA",
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    "Jl. Lebak Bulus Raya No. 1, Daerah Khusus Ibukota Jakarta",
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                  pw.Text(
                    "No Telp. (021) 1234567 - E-mail: hrd@transretail.co.id",
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
            // Spacer Kanan agar info perusahaan benar-benar di tengah
            pw.SizedBox(width: 80),
          ],
        ),
        pw.SizedBox(height: 10),
        // Garis Tebal Bawah Kop
        pw.Divider(thickness: 2),
      ],
    );
  }

  // 2. JUDUL LAPORAN
  static pw.Widget _buildTitle(String title) {
    return pw.Center(
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
          decoration: pw.TextDecoration.underline,
        ),
      ),
    );
  }

  // WIDGET TABEL KARYAWAN
  static pw.Widget _buildEmployeeTable(List<dynamic> employees) {
    final headers = [
      'No',
      'NIK',
      'Nama Karyawan',
      'Departemen',
      'Jabatan',
      'Lokasi Kantor',
    ];

    final List<List<String>> data = List.generate(employees.length, (index) {
      final emp = employees[index];

      // Parsing data dengan aman menggunakan null-aware operator seperti di UI sebelumnya
      final String nik = emp['nik']?.toString() ?? '-';
      final String name = emp['full_name'] ?? '-';
      final String dept = emp['department']?['name'] ?? '-';
      final String position = emp['position']?['name'] ?? emp['role'] ?? '-';
      final String office = emp['office']?['name'] ?? '-';

      return [(index + 1).toString(), nik, name, dept, position, office];
    });

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(width: 1),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellAlignment: pw.Alignment.centerLeft,
      columnWidths: {
        0: const pw.FlexColumnWidth(1), // No
        1: const pw.FlexColumnWidth(2), // NIK
        2: const pw.FlexColumnWidth(4), // Nama (Lebih lebar)
        3: const pw.FlexColumnWidth(3), // Departemen
        4: const pw.FlexColumnWidth(3), // Jabatan
        5: const pw.FlexColumnWidth(3), // Lokasi
      },
    );
  }

  // 3. TABEL DATA DEPARTMENT
  static pw.Widget _buildDepartmentTable(List<dynamic> departments) {
    // Siapkan Header Tabel
    final headers = ['No', 'Nama Departemen', 'Deskripsi'];

    // Mapping data JSON ke bentuk List of Strings untuk tabel
    final List<List<String>> data = List.generate(departments.length, (index) {
      final dept = departments[index];
      return [
        (index + 1).toString(),
        dept['name'] ?? '-',
        dept['description'] ?? '-',
      ];
    });

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(width: 1),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
      cellStyle: const pw.TextStyle(fontSize: 10),
      cellAlignment: pw.Alignment.centerLeft,
      columnWidths: {
        0: const pw.FlexColumnWidth(1), // Kolom No (Kecil)
        1: const pw.FlexColumnWidth(3), // Kolom Nama
        2: const pw.FlexColumnWidth(5), // Kolom Deskripsi (Lebar)
      },
    );
  }

  // WIDGET TABEL OFFICE
  static pw.Widget _buildOfficeTable(List<dynamic> offices) {
    // Header sesuai mockup
    final headers = ['No', 'ID Kantor', 'Nama Kantor', 'Alamat'];

    final List<List<String>> data = List.generate(offices.length, (index) {
      final office = offices[index];

      // Mengambil data dari JSON secara aman
      final String idKantor = office['id']?.toString() ?? '-';
      final String namaKantor = office['name'] ?? '-';
      final String alamat = office['address'] ?? '-';

      return [(index + 1).toString(), idKantor, namaKantor, alamat];
    });

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(width: 1),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
      cellStyle: const pw.TextStyle(fontSize: 10),
      cellAlignment: pw.Alignment.centerLeft,
      columnWidths: {
        0: const pw.FlexColumnWidth(1), // No
        1: const pw.FlexColumnWidth(2), // ID Kantor
        2: const pw.FlexColumnWidth(4), // Nama Kantor
        3: const pw.FlexColumnWidth(5), // Alamat (Paling lebar karena panjang)
      },
    );
  }

  // WIDGET TABEL ABSENSI
  static pw.Widget _buildAttendanceTable(List<dynamic> attendances) {
    final headers = [
      'No',
      'Tanggal',
      'Nama Karyawan',
      'Shift',
      'Jam Masuk',
      'Jam Pulang',
      'Durasi',
      'Status',
    ];

    final List<List<String>> data = List.generate(attendances.length, (index) {
      final att = attendances[index];

      // Parsing Tanggal
      String dateStr = '-';
      if (att['date'] != null) {
        dateStr = DateFormat(
          'dd MMM yyyy',
          'id_ID',
        ).format(DateTime.parse(att['date']).toLocal());
      }

      // Parsing Data Relasi
      final String name = att['user']?['full_name'] ?? '-';
      final String shift = att['shift']?['name'] ?? '-';

      // Parsing Jam Masuk
      String inTime = '-';
      if (att['clock_in_time'] != null) {
        inTime = DateFormat(
          'HH:mm',
        ).format(DateTime.parse(att['clock_in_time']).toLocal());
      }

      // Parsing Jam Pulang
      String outTime = '-';
      if (att['clock_out_time'] != null) {
        outTime = DateFormat(
          'HH:mm',
        ).format(DateTime.parse(att['clock_out_time']).toLocal());
      }

      final String duration = att['work_duration'] ?? '-';
      final String status =
          att['clock_in_status']?.toString().toUpperCase() ?? '-';

      return [
        (index + 1).toString(),
        dateStr,
        name,
        shift,
        inTime,
        outTime,
        duration,
        status,
      ];
    });

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(width: 1),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellAlignment: pw.Alignment.center, // Pusatkan teks agar rapi
      columnWidths: {
        0: const pw.FlexColumnWidth(1), // No
        1: const pw.FlexColumnWidth(3), // Tanggal
        2: const pw.FlexColumnWidth(4), // Nama (Rata Kiri)
        3: const pw.FlexColumnWidth(3), // Shift
        4: const pw.FlexColumnWidth(2), // Masuk
        5: const pw.FlexColumnWidth(2), // Pulang
        6: const pw.FlexColumnWidth(3), // Durasi
        7: const pw.FlexColumnWidth(2), // Status
      },
    );
  }

  // 4. SIGNATURE BLOCK (Kanan Bawah)
  static pw.Widget _buildSignatureBlock(String date) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text("Jakarta, $date", style: const pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 5),
          pw.Text("Mengetahui,", style: const pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 60), // Space untuk tanda tangan
          pw.Text(
            "( ........................................ )",
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            "IT Manager",
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
