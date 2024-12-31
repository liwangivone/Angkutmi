import 'package:intl/intl.dart';

class PaketModel {
  final String price;
  final int duration; // Sudah tipe data int

  PaketModel({
    required this.price,
    required String duration,
  }) : duration = int.tryParse(duration) ?? 0; // Parsing ke int
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
