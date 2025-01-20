import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'modelsinstan.dart';
import 'service/trip_service.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'dana_provider.dart'; // Import DanaProvider
import 'service/payment_service.dart';
import 'track_order.dart';

class Pemesananinstandetail extends StatefulWidget {
  final InputInstanModel input;

  const Pemesananinstandetail({
    Key? key,
    required this.input,
  }) : super(key: key);

  @override
  _PemesananinstandetailState createState() => _PemesananinstandetailState();
}

class _PemesananinstandetailState extends State<Pemesananinstandetail> {
  double price = 0;  // Variabel untuk harga trip
  bool isLoading = false;  // Menandakan jika sedang memuat harga
  int tripid = 0;

  @override
  void initState() {
    super.initState();
    _fetchTripPrice(); // Memanggil fungsi untuk mendapatkan harga
  }

  Future<void> _fetchTripPrice() async {
  final tripService = TripService();
  final tripData = {
    "origin": {"lat": widget.input.lat, "lng": widget.input.lng},
    "vehicle_type": widget.input.vehicle.toLowerCase(),
  };
  print('Trip data dikirim: $tripData');

  setState(() {
    isLoading = true;
  });

  try {
    // Panggil createTrip untuk mendapatkan tripid
    final result = await tripService.createTrip(tripData);
    print('Create trip result: $result');

    if (result['success'] == true) {
      // Pastikan tripid disimpan dalam state
      final int fetchedTripId = result['trip_id'];
      print('Trip ID: $fetchedTripId');

      setState(() {
        tripid = fetchedTripId; // Simpan ke state
      });

      // Panggil getTripPrice untuk mendapatkan harga
      final priceResult = await tripService.getTripPrice(tripid);
      print('Price result: $priceResult');

      setState(() {
        isLoading = false;
        if (priceResult['success'] == true) {
          price = double.parse(priceResult['price'].toString());
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(priceResult['message'] ?? 'Gagal mengambil harga.')),
          );
        }
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Gagal membuat trip.')),
      );
    }
  } catch (e) {
    setState(() {
      isLoading = false;
    });
    print('Error saat mengambil trip: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Terjadi kesalahan: $e')),
    );
  }
}


  Future<void> _lanjutkanPembayaran() async {
  final danaProvider = Provider.of<DanaProvider>(context, listen: false);

  try {
    if (price <= 0) {
      throw Exception("Harga tidak valid!");
    }

    // Kirim data ke server terlebih dahulu
    final paymentService = PaymentService();
    final response = await paymentService.createPayment(
      tripId: tripid,
      price: price,
      paymentMethod: danaProvider.metodePembayaran,
    );
    print("$tripid , ${danaProvider.metodePembayaran}, $price");
    print(response);

    if (response['success']) {
      // Jika pembayaran di backend berhasil, baru kurangi dana
      danaProvider.kurangiDana(price);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Pembayaran berhasil! Sisa saldo: Rp${danaProvider.jumlahDana.toStringAsFixed(0)}",
          ),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PinInputScreen(tripId: tripid)),
      );
    } else {
      throw Exception(response['message'] ?? 'Gagal mengirim data pembayaran.');
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Kesalahan: ${e.toString()}")),
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
                  // Bagian putih melengkung di bawah ygy
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
                                widget.input.address,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        onEdit: () {
                          // fungsi edit utk tombol ubah
                        },
                      ),
                      _buildSection(
                        title: "Jenis kendaraan",
                        content: Row(
                          children: [
                            Text(
                              widget.input.vehicle,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              "Estimasi: ${widget.input.weightEstimate}",
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
                            Consumer<DanaProvider>(
                              builder: (context, danaProvider, child) {
                                return Text(
                                  danaProvider.metodePembayaran,
                                  style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
                                );
                              },
                            ),
                            const Spacer(),
                            Consumer<DanaProvider>(
                              builder: (context, danaProvider, child) {
                                return Text(
                                  "Rp${danaProvider.jumlahDana.toStringAsFixed(0)}",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        onEdit: () {
                          // fungsi edit utk tombol ubah
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total harga",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Menampilkan harga yang sudah diterima dari API (jika harga tersedia)
                          isLoading
                              ? const CircularProgressIndicator()  // Tampilkan loading jika harga sedang dimuat
                              : Text(
                                  price != null
                                      ? "Rp${price!.toStringAsFixed(0)}"  // Tampilkan harga dari server
                                      : "Menunggu harga...",
                                  style: const TextStyle(
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
              onPressed: _lanjutkanPembayaran,
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
    final int tripId;

  const PinInputScreen({
    Key? key,
    required this.tripId,
  }) : super(key: key);
  @override
  _PinInputScreenState createState() => _PinInputScreenState();
}

class _PinInputScreenState extends State<PinInputScreen> {
  
  final int pinLength = 6;
  String inputPin = "";



//   void navigateToTracking(Map<String, dynamic> response) {
//   final tripId = response['data']['trip_id']; // Mengambil trip_id dari response
  
//   Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (context) => OrderTrackingScreen(tripId:tripId),
//     ),
//   );
// }


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
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>OrderTrackingScreen()));
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