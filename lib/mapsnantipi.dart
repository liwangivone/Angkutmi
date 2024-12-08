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
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
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
          // Header hijau melengkung dan form input
          Column(
            children: [
              Stack(
                children: [
                  // Header hijau melengkung
                  Container(
                    height: 250,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 44, 158, 75),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(66.0),
                        bottomRight: Radius.circular(66.0),
                      ),
                    ),
                  ),
                  // Form input di atas header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),
                        const Text(
                          "Nantipi",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _searchController,
                          onSubmitted: _searchLocation,
                          decoration: InputDecoration(
                            hintText: "Masukkan alamat anda",
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
                        const SizedBox(height: 16),
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

class Event {
  final String title;
  final String description;

  Event(this.title, this.description);
}


class DateTimePickerPage extends StatefulWidget {
  @override
  _DateTimePickerPageState createState() => _DateTimePickerPageState();
}

class _DateTimePickerPageState extends State<DateTimePickerPage> {
  DateTime _selectedDate = DateTime.now();
  String _selectedTime = "07:00";
  late ValueNotifier<List<Event>> _selectedEvents;

  @override
  void initState() {
    super.initState();
    _selectedEvents = ValueNotifier([]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pilih Tanggal & Jam"),
        backgroundColor: const Color.fromARGB(255, 44, 158, 75), // Hijau
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(66.0),
            topRight: Radius.circular(66.0),
          ),
        ),
        child: Column(
          children: [
            // TableCalendar untuk pemilihan tanggal
            TableCalendar(
              focusedDay: _selectedDate,
              firstDay: DateTime.utc(2020, 01, 01),
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
                todayTextStyle: TextStyle(color: Colors.black), // Teks hari ini
                selectedDecoration: BoxDecoration(
                  color: Colors.green, // Background hijau saat dipilih
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: TextStyle(color: Colors.white), // Teks saat dipilih
                weekendTextStyle: TextStyle(color: Colors.red), // Hari libur merah
                defaultTextStyle: TextStyle(color: Colors.black), // Teks default hitam
              ),
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                leftChevronIcon: Icon(
                  Icons.chevron_left,
                  color: Colors.white,
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 50), // Memberi jarak pakek sized dlu sementara :) nah
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
            // Tombol Pilih dengan desain custom
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
                  backgroundColor: Colors.green, // Background hijau
                  minimumSize: Size(double.infinity, 50), // Lebar penuh dan tinggi 50
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0), // Sudut membulat
                  ),
                ),
                child: const Text(
                  "Pilih",
                  style: TextStyle(
                    color: Colors.white, // Teks putih
                    fontSize: 18, // Ukuran teks
                  ),
                ),
              ),
            ),
            SizedBox(height: 20), // Memberi jarak setelah tombol
          ],
        ),
      ),
    );
  }
}



