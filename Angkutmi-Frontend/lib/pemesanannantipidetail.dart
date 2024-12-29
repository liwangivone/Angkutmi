// Pemesanannantipidetail.dart
import 'package:flutter/material.dart';
import 'modelsnantipi.dart'; // Pastikan untuk mengimpor model-model yang dibutuhkan

class Pemesanannantipidetail extends StatelessWidget {
  final PaketModel paket;  // Menerima PaketModel
  final AlamatModel alamat;  // Menerima AlamatModel

  // Konstruktor menerima kedua model
  const Pemesanannantipidetail({
    Key? key,
    required this.paket,
    required this.alamat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Pemesanan"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Menampilkan informasi Paket
            Text('Harga: ${paket.price}', style: TextStyle(fontSize: 16)),
            Text('Durasi: ${paket.duration}', style: TextStyle(fontSize: 16)),
            
            SizedBox(height: 20), // Jarak antar informasi
            
            // Menampilkan informasi Alamat
            Text('Alamat: ${alamat.address}', style: TextStyle(fontSize: 16)),
            Text('Tanggal: ${alamat.date}', style: TextStyle(fontSize: 16)),
            Text('Waktu: ${alamat.time}', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
