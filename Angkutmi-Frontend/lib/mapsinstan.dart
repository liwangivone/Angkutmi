import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'pemesananinstandetail.dart';
import 'modelsinstan.dart';

class MapsInstan extends StatefulWidget {
  const MapsInstan();

  @override
  State<MapsInstan> createState() => _MapsInstanState();
}

class _MapsInstanState extends State<MapsInstan> {
  LatLng _selectedLocation = LatLng(-5.147665, 119.432731); // Koordinat awal (Makassar)
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _vehicleController = TextEditingController();
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
           // Print lat dan lon di terminal untuk debugging
          print("Latitude: $lat, Longitude: $lon");

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
          style: const TextStyle(fontFamily: 'Poppins'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation,
              initialZoom: 14.0,
              onTap: (_, point) {
                setState(() {
                  _selectedLocation = point;
                });
                print("Latitude: ${point.latitude}, Longitude: ${point.longitude}");
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
              Stack(
                children: [
                  Container(
                    height: 210,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 44, 158, 75),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40.0),
                        bottomRight: Radius.circular(40.0),
                      ),
                    ),
                  ),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
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
                          readOnly: true,
                          controller: _vehicleController,
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                              ),
                              builder: (BuildContext context) {
                                return DraggableScrollableSheet(
                                  expand: false,
                                  initialChildSize: 0.3,
                                  minChildSize: 0.2,
                                  maxChildSize: 0.4,
                                  builder: (_, controller) {
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
                                        Expanded(
                                          child: ListView(
                                            controller: controller,
                                            children: [
                                              ListTile(
                                                leading: const Icon(Icons.local_shipping, color: Colors.green),
                                                title: const Text("Truck (30 - 50kg)", style: TextStyle(fontFamily: 'Poppins')),
                                                onTap: () {
                                                  setState(() {
                                                    _selectedVehicle = "Truck";
                                                    _vehicleController.text = "Truck (30 - 50kg)";
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
                                                    _vehicleController.text = "Pickup (15 - 29kg)";
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
                                                    _vehicleController.text = "Motor (10 - 14kg)";
                                                  });
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            );
                          },
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
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                  if (_selectedVehicle.isEmpty) {
                    _showErrorDialog("Pilih kendaraan terlebih dahulu!");
                    return;
                  }

                  String weightEstimate = "";
                  if (_selectedVehicle == "Truck") {
                    weightEstimate = "30 - 50kg";
                  } else if (_selectedVehicle == "Pickup") {
                    weightEstimate = "15 - 29kg";
                  } else if (_selectedVehicle == "Motor") {
                    weightEstimate = "10 - 14kg";
                  }
                   // Ambil lat dan lon dari _selectedLocation
                  double lat = _selectedLocation.latitude;
                  double lon = _selectedLocation.longitude;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Pemesananinstandetail(
                        input: InputInstanModel(
                          address: _searchController.text,
                          vehicle: _selectedVehicle,
                          weightEstimate: weightEstimate,
                          lat: lat,  // Ambil nilai latitude
                          lng: lon, // Ambil nilai longitude
                          price: 0.0,  // Harga awal, bisa dihitung setelahnya
                        ),
                      ),
                    ),
                  );
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
