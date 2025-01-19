import 'package:flutter/material.dart';

class DanaProvider extends ChangeNotifier {
  double _jumlahDana = 200000; // Saldo awal
  String metodePembayaran = "OVO";

  double get jumlahDana => _jumlahDana;

  // Mengurangi jumlah dana
  void kurangiDana(double jumlah) {
    if (jumlah <= _jumlahDana) {
      _jumlahDana -= jumlah;
      notifyListeners(); // Memberi tahu UI untuk update
    }
  }
}
