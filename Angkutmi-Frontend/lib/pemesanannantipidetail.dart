import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Untuk memformat dan menghitung tanggal
import 'modelsnantipi.dart'; // Pastikan untuk mengimpor model-model yang dibutuhkan

class Pemesanannantipidetail extends StatelessWidget {
  final PaketModel paket; // Menyimpan data harga paket dan durasi
  final AlamatModel alamat; // Menyimpan data alamat, tanggal, dan waktu

  const Pemesanannantipidetail({
    Key? key,
    required this.paket,
    required this.alamat,
  }) : super(key: key);

  // Fungsi untuk menghitung tanggal berakhir berdasarkan tanggal awal dan durasi paket
  String _calculateEndDate(String startDate, int duration) {
    try {
      // Format input tanggal
      final dateFormat = DateFormat('yyyy-MM-dd'); // Format input
      final start = dateFormat.parse(startDate); // Parsing tanggal awal
      final end = start.add(Duration(days: duration)); // Tambahkan durasi ke tanggal awal

      // Format hasil tanggal akhir
      final outputFormat = DateFormat('d MMMM yyyy', 'id_ID'); // Format lokal Indonesia
      return outputFormat.format(end);
    } catch (e) {
      // Tangani error jika parsing gagal
      return 'Invalid date format';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format tanggal mulai
    final dateFormat = DateFormat('d MMMM yyyy', 'id_ID');
    final startDateFormatted = dateFormat.format(DateFormat('yyyy-MM-dd').parse(alamat.date));

    // Hitung tanggal akhir berdasarkan durasi paket
    final endDate = _calculateEndDate(alamat.date, paket.duration);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C9E4B),
        title: const Text(
          "Konfirmasi Pesanan",
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lokasi Pengangkutan
            _buildSection(
              title: "Lokasi pengangkutan",
              content: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.black),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      alamat.address,
                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tanggal dan Jam
            _buildSection(
              title: "Tanggal dan Jam",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Mulai dari tanggal: $startDateFormatted",
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                  ),
                  Text(
                    "Hingga tanggal: $endDate",
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                  ),
                  Text(
                    "Setiap Jam: ${alamat.time}",
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Informasi Paket
            _buildSection(
              title: "Informasi Paket",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Harga Paket: Rp${paket.price}",
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                  ),
                  Text(
                    "Masa Berlaku Paket: ${paket.duration} hari",
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Metode Pembayaran
            _buildSection(
              title: "Metode pembayaran",
              content: Row(
                children: [
                  const Text(
                    "OVO",
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
                  ),
                  const Spacer(),
                  const Text(
                    "Rp165.000", // Contoh data
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Total Harga
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total harga",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Rp${paket.price}", // Harga total dari paket
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Tombol Lanjutkan ke Pembayaran
            ElevatedButton(
              onPressed: () {
                // Tambahkan logika navigasi ke halaman pembayaran
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C9E4B),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                "Lanjutkan ke pembayaran",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk membuat section
  Widget _buildSection({required String title, required Widget content}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Tambahkan logika untuk mengubah data
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C9E4B),
                    minimumSize: const Size(50, 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: const Text(
                    "Ubah",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: content,
          ),
        ],
      ),
    );
  }
}
