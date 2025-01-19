import 'package:intl/intl.dart';

class PaketModel {
  final String name; // Nama paket
  final double price; // Harga sekarang dalam bentuk double
  final int duration; // Durasi tetap dalam bentuk integer (opsional)

  PaketModel({
    required String name,
    required String price,
    required String duration,
  })  : name = name,
        price = _parsePrice(price),
        duration = _parseDuration(duration);

  // Fungsi untuk memproses string harga (misalnya, "Rp45.000" -> 45000.0)
  static double _parsePrice(String priceString) {
    final cleanedString = priceString.replaceAll(RegExp(r'[^\d]'), ''); // Hapus karakter non-angka
    return double.tryParse(cleanedString) ?? 0.0; // Parsing ke double atau 0.0 jika gagal
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
  final double lat;  // Tetap sebagai `lat`
  final double lng;  // Ubah dari `lon` menjadi `lng`
  
  AlamatModel({
    required this.address,
    required this.date,
    required this.time,
    required this.lat,
    required this.lng, // Perbaikan di sini
  });

  // Fungsi untuk mengonversi model ke Map
  Map<String, dynamic> toMap() {
    return {
      'address': address,
      'date': date,
      'time': time,
      'lat': lat,
      'lng': lng, // Gunakan `lng` di sini
    };
  }

  // Fungsi untuk membuat model dari Map
  factory AlamatModel.fromMap(Map<String, dynamic> map) {
    return AlamatModel(
      address: map['address'],
      date: map['date'],
      time: map['time'],
      lat: map['lat'],
      lng: map['lng'], // Gunakan `lng` di sini
    );
  }
}

class ActivePaketModel {
  final String name;
  final double price;
  final int duration;
  final String startDate;
  final String endDate;
  final String address;

  ActivePaketModel({
    required this.name,
    required this.price,
    required this.duration,
    required this.startDate,
    required this.endDate,
    required this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'duration': duration,
      'startDate': startDate,
      'endDate': endDate,
      'address': address,
    };
  }

  factory ActivePaketModel.fromMap(Map<String, dynamic> map) {
    return ActivePaketModel(
      name: map['name'],
      price: map['price'],
      duration: map['duration'],
      startDate: map['startDate'],
      endDate: map['endDate'],
      address: map['address'],
    );
  }
}

