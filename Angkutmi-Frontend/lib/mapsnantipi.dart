import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;

class Maps extends StatefulWidget {
  const Maps({Key? key}) : super(key: key);

  @override
  State<Maps> createState() => _MapState();
}

class _MapState extends State<Maps> {
  LatLng _selectedLocation = LatLng(-5.147665, 119.432731); // Koordinat awal (Makassar)
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _dateController = TextEditingController(); // Controller untuk tanggal
  final TextEditingController _timeController = TextEditingController(); // Controller untuk jam

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
                    // top: 30,
                    // left: 16,
                    // right: 16,
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
                          "Nantipi",
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
                  // Form input di atas header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                        TextFormField(
                          controller: _dateController,
                          readOnly: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => DateTimePickerPage()),
                            ).then((value) {
                              if (value != null) {
                                setState(() {
                                  _dateController.text = value['date'];
                                  _timeController.text = value['time'];
                                });
                              }
                            });
                          },
                          decoration: InputDecoration(
                            hintText: "Tentukan tanggal & jam pengangkutan",
                            hintStyle: const TextStyle(fontFamily: 'Poppins'),
                            prefixIcon: const Icon(Icons.calendar_today, color: Colors.green),
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
            ],
          ),
        ],
      ),
    );
  }
}

class DateTimePickerPage extends StatefulWidget {
  @override
  _DateTimePickerPageState createState() => _DateTimePickerPageState();
}

class _DateTimePickerPageState extends State<DateTimePickerPage> {
  DateTime _selectedDate = DateTime.now();
  String _selectedTime = "07:00";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
  preferredSize: const Size.fromHeight(200), // Tinggi total AppBar
  child: Stack(
    children: [
      // Background hijau (turun lebih bawah)
      Container(
        margin: const EdgeInsets.only(top: 0), // Turunkan header hijau
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 44, 158, 75), // Warna hijau
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(66.0),
            bottomRight: Radius.circular(66.0),
          ),
        ),
        height: 120, // Atur tinggi background hijau
      ),
      // Teks dan ikon tetap di atas
      Positioned(
        top: 0, // Atur posisi teks di atas
        left: 0,
        right: 0,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 28,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(width: 8), // Jarak ikon ke teks
            const Text(
              "Pilih Tanggal & Jam",
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
    ],
  ),
),








     body: Column(
        children: [
          Stack(
            children: [
              // Header bawah melengkung hijau
              // Container(
              //   height: 80, // Tinggi header
              //   decoration: const BoxDecoration(
              //     color: const Color.fromARGB(255, 44, 158, 75),
              //     borderRadius: BorderRadius.only(
              //       bottomLeft: Radius.circular(66.0),
              //       bottomRight: Radius.circular(66.0),
              //     ),
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: TableCalendar(
                  focusedDay: _selectedDate,
                  firstDay: DateTime.now(), // Blokir tanggal yang sudah lewat
                  lastDay: DateTime.utc(2030, 12, 31),
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDate, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDate = selectedDay;
                    });
                  },
                  calendarStyle: CalendarStyle(
                    todayTextStyle: TextStyle(color: Colors.black),
                    
                    selectedDecoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: TextStyle(color: Colors.white),
                    weekendTextStyle: TextStyle(color: Colors.red),
                    defaultTextStyle: TextStyle(color: Colors.black),
                  ),
                  headerStyle: HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: false,
                    leftChevronIcon: Icon(
                      Icons.chevron_left,
                      color: Colors.black,
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 35),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(
              12,
              (index) {
                String time = "${7 + index}:00";
                return ChoiceChip(
                  label: Text(
                    time,
                    style: TextStyle(
                      color: _selectedTime == time ? Colors.white : Colors.green,
                    ),
                  ),
                  selected: _selectedTime == time,
                  selectedColor: Colors.green,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: Colors.green,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  onSelected: (_) {
                    setState(() {
                      _selectedTime = time;
                    });
                  },
                );
              },
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  {
                    'date': "${_selectedDate.toLocal()}".split(' ')[0],
                    'time': _selectedTime,
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                "Pilih",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

