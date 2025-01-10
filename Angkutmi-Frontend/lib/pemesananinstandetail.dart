import 'package:flutter/material.dart';
import 'modelsinstan.dart';
import 'service/api_service.dart';

class Pemesananinstandetail extends StatelessWidget {
  final InputInstanModel input;

  const Pemesananinstandetail({
    Key? key,
    required this.input,
  }) : super(key: key);

 
  Future<void> createTrip(BuildContext context) async {
    final tripData = {
      "origin": {"lat": -5.135399, "lng": 119.412293},
      "destination": {"lat": -5.135831, "lng": 119.422559},
      "destination_name": "Mall Panakkukang",
      "vehicle_type": "motor",
    };

    final tripService = TripService();

    // Tampilkan indikator loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      final result = await tripService.createTrip(tripData);

      // Tutup indikator loading
      Navigator.pop(context);

      if (result['success'] == true) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PinInputScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal menyimpan data. Silakan coba lagi.")),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Tutup indikator loading
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Terjadi kesalahan. Silakan coba lagi.")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              // Header hijau dengan lengkungan melengkung
              Stack(
                children: [
                  Container(
                    height: 160,
                   color: const Color.fromARGB(255, 44, 158, 75),

                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 40.0),
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
                              "Konfirmasi Pesanan",
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
                    ),
                  ),
                  // Bagian putih melengkung di bawah
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(66.0),
                          topRight: Radius.circular(66.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 2, left: 12, right: 12, bottom: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection(
                        title: "Lokasi pengangkutan",
                        content: Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.black),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                input.address,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        onEdit: () {
                          // fungsi edit utk tomboll ubah
                        },
                      ),
                      _buildSection(
                      title: "Jenis kendaraan",
                      content: Row(
                        children: [
                          Text(
                            input.vehicle,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "Estimasi: ${input.weightEstimate}",
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      onEdit: () {
                        // fungsi edit utk tombol ubah
                      },
                    ),
                      _buildSection(
                        title: "Metode pembayaran",
                        content: Row(
                          children: [
                            const Text(
                              "OVO",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              "Rp165.000",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        onEdit: () {
                          // fungsi edit utk tomboll ubah
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            "Total harga",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Rp165.000",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      
                    ],
                  ),
                ),
              ),
              
            ],
          ),
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PinInputScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C9E4B),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                "Lanjutkan ke pembayaran",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
  required String title,
  required Widget content,
  VoidCallback? onEdit,
}) {
  return Container(
    
    margin: const EdgeInsets.only(bottom: 12.0),
    padding: const EdgeInsets.symmetric(vertical: 16.0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8.0),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              ElevatedButton(
                onPressed: onEdit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(50, 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                child: const Text(
                  "Ubah",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: content,
        ),
      ],
    ),
  );
}

}


class PinInputScreen extends StatefulWidget {
  @override
  _PinInputScreenState createState() => _PinInputScreenState();
}

class _PinInputScreenState extends State<PinInputScreen> {
  final int pinLength = 6;
  String inputPin = "";

  void _onKeyPress(String value) {
    if (value == "backspace") {
      if (inputPin.isNotEmpty) {
        setState(() {
          inputPin = inputPin.substring(0, inputPin.length - 1);
        });
      }
    } else {
      if (inputPin.length < pinLength) {
        setState(() {
          inputPin += value;
        });
      }
    }
  }

  void _onConfirm() {
    if (inputPin.length == pinLength) {
      // Lakukan validasi atau navigasi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("PIN berhasil: $inputPin")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Masukkan PIN lengkap!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C9E4B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C9E4B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 50),
          const Text(
            'Masukkan pin anda',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              pinLength,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor:
                      index < inputPin.length ? Colors.white : Colors.white38,
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildKeypadRow(["1", "2", "3"]),
                _buildKeypadRow(["4", "5", "6"]),
                _buildKeypadRow(["7", "8", "9"]),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const SizedBox(width: 60), // Placeholder untuk kiri kosong
                    _buildKeypadButton("0"),
                    _buildKeypadButton("backspace"),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Padding(
          padding: const EdgeInsets.only(bottom: 24.0), // Tambahkan jarak 24 pixel dari bawah
          child: ElevatedButton(
            onPressed: () {
              _onConfirm();
              if (inputPin.length == pinLength) {
                Navigator.pushNamed(context, '/home');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text(
              'OK',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                color: Color(0xFF2C9E4B),
              ),
            ),
          ),
        ),

          
        ],
      ),
    );
  }

  Widget _buildKeypadRow(List<String> keys) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: keys.map((key) => _buildKeypadButton(key)).toList(),
      ),
    );
  }

  Widget _buildKeypadButton(String key) {
    return SizedBox(
      width: 60,
      height: 60,
      child: GestureDetector(
        onTap: () => _onKeyPress(key),
        child: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.transparent,
          child: key == "backspace"
              ? const Icon(Icons.backspace, color: Colors.white)
              : Text(
                  key,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
