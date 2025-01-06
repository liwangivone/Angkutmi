import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'pemesanannantipidetail.dart';
import 'modelsnantipi.dart';

class MapsInstan extends StatefulWidget {
  

  const MapsInstan();

  @override
  State<MapsInstan> createState() => _MapsInstanState();
}

class _MapsInstanState extends State<MapsInstan> {
  LatLng _selectedLocation = LatLng(-5.147665, 119.432731); // Koordinat awal (Makassar)
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  String _selectedVehicle = "";

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;

    final url = Uri.parse(
        "https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=1");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List results = json.decode(response.body);
        if (results.isNotEmpty) {
          final lat = double.parse(results[0]['lat']);
          final lon = double.parse(results[0]['lon']);

          setState(() {
            _selectedLocation = LatLng(lat, lon);
          });

          // Pindahkan peta ke lokasi hasil pencarian
          _mapController.move(_selectedLocation, 14.0);
        } else {
          _showErrorDialog("Alamat tidak ditemukan");
        }
      } else {
        _showErrorDialog("Gagal mencari lokasi");
      }
    } catch (e) {
      _showErrorDialog("Terjadi kesalahan: $e");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          "Error",
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        content: Text(
          message,
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "OK",
              style: TextStyle(fontFamily: 'Poppins'),
            ),
          ),
        ],
      ),
    );
  }
  final TextEditingController _vehicleController = TextEditingController();

  void _showVehiclePicker() {
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Pilih jenis kendaraan",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.local_shipping, color: Colors.green),
              title: const Text("Truck (30 - 50kg)", style: TextStyle(fontFamily: 'Poppins')),
              onTap: () {
                setState(() {
                  _selectedVehicle = "Truck";
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.fire_truck, color: Colors.green),
              title: const Text("Pickup (15 - 29kg)", style: TextStyle(fontFamily: 'Poppins')),
              onTap: () {
                setState(() {
                  _selectedVehicle = "Pickup";
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.motorcycle, color: Colors.green),
              title: const Text("Motor (10 - 14kg)", style: TextStyle(fontFamily: 'Poppins')),
              onTap: () {
                setState(() {
                  _selectedVehicle = "Motor";
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Peta Flutter
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation,
              initialZoom: 14.0,
              onTap: (_, point) {
                setState(() {
                  _selectedLocation = point;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point: _selectedLocation,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  )
                ],
              ),
            ],
          ),
          Column(
            children: [
              // Header dan input
              Stack(
                children: [
                  // Header hijau melengkung
                  Container(
                    height: 210,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 44, 158, 75),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(66.0),
                        bottomRight: Radius.circular(66.0),
                      ),
                    ),
                  ),
                  // Tombol back dan teks "Nantipi" di atas header
                  Positioned(
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
                          "Angkutmi",
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
                  // Form input
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 70),
                        TextField(
                          controller: _searchController,
                          onSubmitted: _searchLocation,
                          decoration: InputDecoration(
                            hintText: "Masukkan alamat anda",
                            hintStyle: const TextStyle(fontFamily: 'Poppins'),
                            prefixIcon: const Icon(Icons.search, color: Colors.green),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(color: Colors.green, width: 2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(color: Colors.green, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
  readOnly: true, // Membuat TextField hanya bisa dibaca
  controller: _vehicleController, // Controller untuk menampilkan pilihan kendaraan
  onTap: _showVehiclePicker, // Memanggil fungsi untuk menampilkan pilihan kendaraan
  decoration: InputDecoration(
    hintText: "Pilih jenis kendaraan",
    hintStyle: const TextStyle(fontFamily: 'Poppins'),
    prefixIcon: const Icon(Icons.directions_car, color: Colors.green),
    filled: true,
    fillColor: Colors.white,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(color: Colors.green, width: 2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(color: Colors.green, width: 2),
    ),
  ),
),

                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Tombol Tetapkan
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (_selectedVehicle.isEmpty) {
                      _showErrorDialog("Pilih kendaraan terlebih dahulu!");
                      return;
                    }
                    // Navigator.push( //belumpii saya buat untuk detail nya instan
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => Pemesanannantipidetail(
                    //       paket: widget.paket,
                    //       alamat: AlamatModel(
                    //         address: _searchController.text,
                    //         date: _selectedVehicle,
                    //         time: "",
                    //       ),
                    //     ),
                    //   ),
                    // );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C9E4B),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "Tetapkan",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
