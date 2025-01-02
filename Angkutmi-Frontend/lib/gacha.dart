import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // For secure storage
import 'service/gacha_service.dart'; // Import the service class for fetching wheel slices

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  _ExamplePageState createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  StreamController<int> selected = StreamController<int>();
  final FlutterSecureStorage storage = FlutterSecureStorage(); // Instance of secure storage
  String token = "";
  List<Map<String, dynamic>> wheelSlices = []; // List to hold wheel slices
  String selectedReward = ''; // To store the selected reward name
  String selectedImg = ''; // To store the selected image URL
  double progress = 0.0; // Variable to hold the progress

  // GachaService instance to interact with the backend API
  final GachaService gachaService = GachaService();

  // Get token from secure storage
  Future<void> getToken() async {
    try {
      final token = await storage.read(key: 'auth_token');
      if (token != null) {
        setState(() {
          this.token = token;
        });
      }
    } catch (e) {
      print('Error retrieving token: $e');
    }
  }

  // Fetch the wheel slices from the backend
Future<void> fetchWheelSlices() async {
  try {
    final slices = await gachaService.fetchWheelSlices();

    // Debug: Print fetched slices
    print('Fetched slices from API: $slices');

    if (slices != null && slices is List<Map<String, dynamic>>) {
      setState(() {
        wheelSlices = slices; // Assign fetched slices to the UI
      });
    } else {
      throw Exception('Unexpected response format: $slices');
    }
  } catch (e) {
    print("Error fetching wheel slices: $e");
  }
}

void spinWheel() async {
  try {
    // Fetch the backend response
    final response = await gachaService.spinWheel();

    if (response != null) {
      // Debug: Log the backend response
      print("Full JSON Response: $response");

      // Debug: Log the progress value
      print("Progress from API: ${response['progress']}");

      // Update progress
      setState(() {
        progress = response['progress'] / 100.0; // Normalize progress (0-1)
      });

      // Find the selected slice based on the backend response
      final selectedSlice = wheelSlices.firstWhere(
        (slice) => slice['label'] == response['slice']['label'],
        orElse: () => {}, // Return an empty map instead of null
      );

      if (selectedSlice.isNotEmpty) {
        final selectedIndex = wheelSlices.indexOf(selectedSlice);

        // Debug: Log selected slice and index
        print("Selected Slice Index: $selectedIndex");
        print("Selected Slice Details: $selectedSlice");

        setState(() {
          // Update the reward details
          setReward(selectedIndex);

          // Spin the wheel to the selected index
          selected.add(selectedIndex);
        });
      } else {
        print("Error: No matching slice found for ${response['slice']['label']}");
      }

      // Show progress bar full dialog if progress reaches 100%
      if (progress == 1.0) {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Roda Penuh!"),
              content: const Text("Bar Anda sudah penuh. Silakan klaim hadiah Anda!"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                    // Optionally trigger any additional actions to claim the reward
                  },
                  child: const Text("Klaim Hadiah"),
                ),
              ],
            );
          },
        );
      }
    } else {
      print("Error: Response is null");
    }
  } catch (e) {
    print("Error spinning the wheel: $e");
  }
}


  // Set reward details when a slice is selected
  void setReward(int index) {
    selectedReward = wheelSlices[index]['label'] ?? 'Unnamed Slice';
    selectedImg = wheelSlices[index]['img'] ?? ''; // Assuming the image URL is stored as 'img'
  }

  // Close the dialog and update progress
  void closeDialog() {
    setState(() {
      // You can optionally call the API again here if you need to update the progress after closing
      fetchWheelSlices();  // Re-fetch wheel slices if needed
    });
    Navigator.pop(context); // Close the dialog
  }

  @override
  void initState() {
    super.initState();
    getToken(); // Retrieve token when the page loads
    fetchWheelSlices(); // Fetch wheel slices when the page loads
  }

  @override
  void dispose() {
    selected.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Roda Keberuntungan'),
        backgroundColor: const Color.fromARGB(255, 44, 158, 75),
      ),
      backgroundColor: const Color.fromARGB(255, 44, 158, 75),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(66.0),
            topRight: Radius.circular(66.0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              Center(
                child: ElevatedButton(
                  onPressed: spinWheel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text("Spin the Wheel"),
                ),
              ),
              const SizedBox(height: 20),

              // Progress bar below the spin button
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: const Color.fromARGB(255, 255, 242, 178),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 158, 215, 99)),
                      minHeight: 10.0,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%', // Display percentage
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: MediaQuery.of(context).size.height / 2,
                        child: wheelSlices.isNotEmpty && wheelSlices.length > 1
                            ? FortuneWheel(
                                selected: selected.stream,
                                items: [
                                  for (var slice in wheelSlices)
                                    FortuneItem(
                                      child: Text(
                                        slice['label'] ?? 'Unnamed Slice',
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                ],
onAnimationEnd: () {
  // Show the reward in a dialog after the animation ends
  showDialog(
    barrierDismissible: true,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Selamat! Anda Mendapatkan"),
        content: Column(
          children: [
            const SizedBox(height: 10),
            Text(
              selectedReward,
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 20),
            selectedImg.isNotEmpty
                ? Image.network(selectedImg)
                : const SizedBox(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: closeDialog,
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
},

                                onFocusItemChanged: (value) {
                                  setReward(value); // Set reward details when the slice is selected
                                },
                              )
                            : const Center(
                                child: CircularProgressIndicator(),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
