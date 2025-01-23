import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // For secure storage
import 'service/gacha_service.dart'; // Import the service class for fetching wheel slices

class GachaPage extends StatefulWidget {
  const GachaPage({super.key});

  @override
  _ExamplePageState createState() => _ExamplePageState();
}

class _ExamplePageState extends State<GachaPage> {
  StreamController<int> selected = StreamController<int>();
  final FlutterSecureStorage storage = FlutterSecureStorage(); // Instance of secure storage
  String token = "";
  List<Map<String, dynamic>> wheelSlices = []; // List to hold wheel slices
  String selectedReward = ''; // To store the selected reward name
  String selectedImg = ''; // To store the selected image URL
  double progress = 0.0; // Variable to hold the progress
  int tripsCompleted = 0; // Variable to track completed trips

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

  // Fetch current progress from the backend
// Fetch current progress from the backend
Future<void> fetchProgress() async {
  try {
    final progressData = await gachaService.fetchProgress();

    if (progressData != null) {
      setState(() {
        progress = progressData['progress'] / 100.0; // Normalize progress (0-1)
        tripsCompleted = progressData['trips_completed']; // Update tripsCompleted with trip_count
      });
    } else {
      print("Error: No progress data received");
    }
  } catch (e) {
    print("Error fetching progress: $e");
  }
}
void spinWheel() async {
  fetchProgress();
  if (tripsCompleted < 3) { // Check if trips completed is less than 3
    // Show a popup if the user hasn't completed 3 trips
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Tidak cukup trip"),
          content: const Text("Selesaikan tiga trip untuk memutar roda"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); 
                fetchProgress();// Close the dialog
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
    return; // Exit the function if not enough trips
  }

    try {
      // Fetch the backend response
      final response = await gachaService.spinWheel();

      if (response != null) {
        // Debug: Log the backend response
        print("Full JSON Response: $response");

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

          // Fetch and update progress after the spin completes
          fetchProgress(); // Fetch the updated progress
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
  void closeDialog() {Navigator.pop(context); 
    setState(() {
      // You can optionally call the API again here if you need to update the progress after closing
      fetchWheelSlices();  // Re-fetch wheel slices if needed
    });
    // Close the dialog
  }

  @override
  void initState() {
    super.initState();
    getToken();  // Retrieve token when the page loads
    fetchWheelSlices();  // Fetch wheel slices when the page loads
    fetchProgress();  // Fetch the user's progress when the page loads
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28,), // Change icon color to yellow
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text(
          'Roda Keberuntungan',
          style: TextStyle(color: Colors.white), // Change font color to white
        ),
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
          padding: const EdgeInsets.only(left: 35, right: 35, top: 40),
          child: Column(
            children: [
              Center(
                child: ElevatedButton(
                  onPressed: spinWheel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text(
                    "Putar Roda",
                    style: TextStyle(color: Colors.white), // Change text color to white
                  ),
                ),
              ),
              const SizedBox(height: 50),

              // Progress bar below the spin button
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity, // Make the progress bar full width
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: const Color.fromARGB(255, 255, 242, 178),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 44, 158, 75)),
                        minHeight: 10.0,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              // Claim button when progress reaches 100%
              if (progress >= 1.0) // Check if progress is 100%
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: ElevatedButton(
                    onPressed: claimReward,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 231, 216, 80),
                      minimumSize: const Size(200, 60), // Make the button bigger
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Change the radius here
                      ),
                    ),
                    child: const Text("Claim Reward !", style: TextStyle(fontSize: 18, color: Colors.black)), // Optional: Increase text size
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
                                  for (var index = 0; index < wheelSlices.length; index++)
                                    FortuneItem(
                                      child: Text(
                                        wheelSlices[index]['label'] ?? 'Unnamed Slice',
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      style: FortuneItemStyle(
                                        color: index % 2 == 0 
                                            ? const Color.fromARGB(255, 44, 158, 75) // Green for even index
                                            : const Color.fromARGB(255, 158, 215, 99), // Alternate color for odd index
                                        borderColor: Color.fromARGB(255, 158, 215, 99),
                                        borderWidth: 10.0, // Change border thickness here
                                      ),
                                    ),
                                ],
                                animateFirst: false, // Prevent initial animation
                                // Change the color of the wheel
                                indicators: <FortuneIndicator>[
                                  FortuneIndicator(
                                    alignment: Alignment.topCenter,
                                    child: TriangleIndicator(
                                      color: Colors.red, // Change the color here
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
                                          mainAxisSize: MainAxisSize.min, // Add this to prevent overflow
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
                                            style: TextButton.styleFrom(
                                              foregroundColor: const Color.fromARGB(255, 44, 158, 75),
                                            ),
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  // Fetch and update progress after the animation ends
                                  fetchProgress(); // Remove await since we don't need to wait for it
                                },
                                onFocusItemChanged: (value) {
                                  setReward(value); // Set reward details when the slice is selected
                                },
                              )
                            : Center(
                                child: CircularProgressIndicator(
                                  color: const Color.fromARGB(255, 44, 158, 75),
                                ),
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

    Future<void> claimReward() async {
    try {
      final response = await gachaService.claimReward();

      if (response != null && response['status'] == 'success') {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Reward Claimed!"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    response['message'] ?? "You have successfully claimed your reward!",
                    style: const TextStyle(fontSize: 18),
                  ),
                  if (response['reward'] != null)
                    Column(
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          "Reward: ${response['reward']['label']}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        response['reward']['img'] != null
                            ? Image.network(response['reward']['img'])
                            : const SizedBox(),
                      ],
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    fetchProgress();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color.fromARGB(255, 44, 158, 75),
                  ),
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Success"),
              content: Text(response['message'] ?? "Failed to claim the reward."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color.fromARGB(255, 44, 158, 75),
                  ),
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print("Error claiming the reward: $e");

      // Show an error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: const Text("An error occurred while claiming the reward."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 44, 158, 75),
                ),
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }
}