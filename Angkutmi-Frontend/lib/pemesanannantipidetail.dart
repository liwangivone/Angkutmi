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

  String _calculateEndDate(String startDate, int duration) {
    try {
      final dateFormat = DateFormat('yyyy-MM-dd');
      final start = dateFormat.parse(startDate);
      final end = start.add(Duration(days: duration));

      final outputFormat = DateFormat('d MMMM yyyy', 'id_ID');
      return outputFormat.format(end);
    } catch (e) {
      return 'Invalid date format';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMMM yyyy', 'id_ID');
    final startDateFormatted = dateFormat.format(DateFormat('yyyy-MM-dd').parse(alamat.date));
    final endDate = _calculateEndDate(alamat.date, paket.duration);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              // Header hijau dengan lengkungan melengkung
              Stack(
                children: [
                  Container(
                    height: 160,
                    color: const Color.fromARGB(255, 44, 158, 75),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 40.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "Detail Pemesanan",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Bagian putih melengkung di bawah
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(66.0),
                          topRight: Radius.circular(66.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                              "Rp165.000",
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
                            "Rp${paket.price}",
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: () {},
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
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget content}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
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
                    fontSize: 16,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
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
