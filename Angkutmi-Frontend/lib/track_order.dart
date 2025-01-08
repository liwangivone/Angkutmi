import 'package:flutter/material.dart';

// class OrderTrackingApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: OrderTrackingScreen(),
//     );
//   }
// }

class OrderTrackingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 44, 158, 75),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Lacak pesanan',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // Header with rounded background
          Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 44, 158, 75),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kamis, 4 Desember 2024',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Nomor Pesanan: #25693',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Order tracking steps
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 60),
              child: Column(
                children: [
                  TrackingStep(
                    label: 'Pesanan diterima',
                    isCompleted: true,
                  ),
                  TrackingStep(
                    label: 'Driver sedang menuju lokasi',
                    isCompleted: true,
                  ),
                  TrackingStep(
                    label: 'Berhasil diangkut',
                    isCompleted: false,
                  ),
                  Spacer(),
                  // Estimated time
                  Text(
                    'Estimasi waktu: 11 menit',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 30),
                  // Back to Home button
                  ElevatedButton(
                  onPressed: () {
                    },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 44, 158, 75),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Kembali ke Beranda',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                SizedBox(height: 30), // Added bottom padding/margin
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TrackingStep extends StatelessWidget {
  final String label;
  final bool isCompleted;

  const TrackingStep({
    required this.label,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            // Checkmark or Circle
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? Colors.green : Colors.grey.shade300,
              ),
              child: isCompleted
                  ? Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            // Vertical Line
            Container(
              width: 2,
              height: 50,
              color: isCompleted ? Colors.green : Colors.grey.shade300,
            ),
          ],
        ),
        SizedBox(width: 20),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              label,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
