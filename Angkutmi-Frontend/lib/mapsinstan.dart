import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'pemesananinstandetail.dart';
import 'modelsinstan.dart';
import 'service/trip_service.dart';

class MapsInstan extends StatefulWidget {
  const MapsInstan();
  

  @override
  State<MapsInstan> createState() => _MapsInstanState();
}


class _MapsInstanState extends State<MapsInstan> {
  LatLng _selectedLocation = LatLng(-5.147665, 119.432731);
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _vehicleController = TextEditingController();
  String _selectedVehicle = "";
  bool _locationValid = false;
  bool _isButtonDisabled = false;
  bool _isRequestInProgress = false;

  Future<bool> createTrip(BuildContext context, InputInstanModel input) async {
  final tripData = {
    "origin": {"lat": input.lat, "lng": input.lng},
    "vehicle_type": input.vehicle.toLowerCase(),
  };

  final tripService = TripService();

  // Avoid duplicate requests
  if (_isRequestInProgress) return false;
  setState(() {
    _isRequestInProgress = true; // Set flag to true when request starts
  });

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const Center(child: CircularProgressIndicator());
    },
  );

  try {
    final result = await tripService.createTrip(tripData);

    if (result['success'] == true) {
      final tripId = result['trip_id'];
      if (tripId == null) {
        throw Exception('Trip ID tidak ditemukan.');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Trip berhasil dibuat dengan ID: $tripId")),
      );
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? "Gagal membuat trip.")),
      );
      return false;
    }
  } catch (e) {
    print("Error: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Terjadi kesalahan. Silakan coba lagi.")),
    );
    return false;
  } finally {
    setState(() {
      _isRequestInProgress = false; // Reset flag to false after request finishes
    });
    if (Navigator.canPop(context)) {
      Navigator.pop(context); // Close dialog
    }
  }
}



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
            _locationValid = true;
          });
          _mapController.move(_selectedLocation, 14.0);
        } else {
          setState(() {
            _locationValid = false;
          });
          _showErrorDialog("Alamat tidak ditemukan");
        }
      } else {
        setState(() {
          _locationValid = false;
        });
        _showErrorDialog("Gagal mencari lokasi");
      }
    } catch (e) {
      setState(() {
        _locationValid = false;
      });
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
                  _locationValid = true;
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
              Stack(
                children: [
                  Container(
                    height: 240,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 44, 158, 75),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40.0),
                        bottomRight: Radius.circular(40.0),
                      ),
                    ),
                  ),
                  AppBar(
                    title: const Text(
                      "Angkutmi",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    backgroundColor: const Color.fromARGB(255, 44, 158, 75),
                    elevation: 0,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 100),
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
  onPressed: _locationValid && !_isButtonDisabled
      ? () async {
          setState(() {
            _isButtonDisabled = true; // Disable the button temporarily
          });

          if (_selectedVehicle.isEmpty) {
            _showErrorDialog("Pilih kendaraan terlebih dahulu!");
            setState(() {
              _isButtonDisabled = false;
            });
            return;
          }

          if (_searchController.text.trim().isEmpty) {
            _showErrorDialog("Masukkan alamat Anda terlebih dahulu!");
            setState(() {
              _isButtonDisabled = false;
            });
            return;
          }

          // Determine weightEstimate based on selected vehicle
          String weightEstimate = "";
          if (_selectedVehicle == "Truck") {
            weightEstimate = "30 - 50kg";
          } else if (_selectedVehicle == "Pickup") {
            weightEstimate = "15 - 29kg";
          } else if (_selectedVehicle == "Motor") {
            weightEstimate = "10 - 14kg";
          }

          // Process input and create the trip
          double lat = _selectedLocation.latitude;
          double lon = _selectedLocation.longitude;

          final inputModel = InputInstanModel(
            address: _searchController.text,
            vehicle: _selectedVehicle,
            weightEstimate: weightEstimate,
            lat: lat,
            lng: lon,
            price: 0.0,
          );

          final tripCreated = await createTrip(context, inputModel);
          setState(() {
            _isButtonDisabled = false; // Enable the button again
          });

          if (tripCreated) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Pemesananinstandetail(input: inputModel),
              ),
            );
          }
        }
      : null,
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF2C9E4B), // Active button color
    disabledBackgroundColor: const Color.fromARGB(130, 139, 139, 139), // Disabled button color
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
)

),

            ],
          ),
        ],
      ),
    );
  }
}
