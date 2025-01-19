import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'modelsnantipi.dart';

class ActivePaketProvider extends ChangeNotifier {
  List<ActivePaketModel> _activePakets = [];
  
  List<ActivePaketModel> get activePakets => _activePakets;

  Future<void> addActivePaket(ActivePaketModel paket) async {
    _activePakets.add(paket);
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> loadActivePakets() async {
    final prefs = await SharedPreferences.getInstance();
    final String? paketsJson = prefs.getString('active_pakets');
    
    if (paketsJson != null) {
      final List<dynamic> decoded = json.decode(paketsJson);
      _activePakets = decoded
          .map((item) => ActivePaketModel.fromMap(item))
          .toList();
      notifyListeners();
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(
      _activePakets.map((paket) => paket.toMap()).toList(),
    );
    await prefs.setString('active_pakets', encoded);
  }
}



