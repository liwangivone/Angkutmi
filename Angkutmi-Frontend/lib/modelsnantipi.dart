import 'package:intl/intl.dart';

class PaketModel {
  final int price; // Harga sekarang dalam bentuk integer
  final int duration; // Durasi tetap dalam bentuk integer

  PaketModel({
    required String price,
    required String duration,
  })  : price = _parsePrice(price),
        duration = _parseDuration(duration);

  // Fungsi untuk memproses string harga (misalnya, "Rp45.000" -> 45000)
  static int _parsePrice(String priceString) {
    final cleanedString = priceString.replaceAll(RegExp(r'[^\d]'), ''); // Hapus karakter non-angka
    return int.tryParse(cleanedString) ?? 0; // Parsing ke integer atau 0 jika gagal
  }

  // Fungsi untuk memproses string durasi (misalnya, "30 hari" -> 30)
  static int _parseDuration(String durationString) {
    final RegExp regex = RegExp(r'\d+'); // Cari angka dalam string
    final match = regex.firstMatch(durationString);
    return match != null ? int.parse(match.group(0)!) : 0; // Kembalikan angka atau 0 jika tidak ada
  }
}




class AlamatModel {
  final String address;
  final String date; // Date dalam format string
  final String time;

  AlamatModel({
    required this.address,
    required this.date,
    required this.time,
  });

  // Fungsi untuk mendapatkan DateTime dari string date
  DateTime get parsedDate {
    return DateFormat('d MMMM yyyy').parse(date); // Format sesuai input
  }
}
