import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Untuk memformat dan menghitung tanggal
import 'modelsnantipi.dart'; // Pastikan untuk mengimpor model-model yang dibutuhkan
import 'service/api_langganan.dart'; // Pastikan path API benar
import 'dana_provider.dart';
import 'package:provider/provider.dart';
import 'active_paket_provider.dart';

class Pemesanannantipidetail extends StatelessWidget {
  final PaketModel paket; // Menyimpan data harga paket dan durasi
  final AlamatModel alamat; // Menyimpan data alamat, tanggal, dan waktu
  

  const Pemesanannantipidetail({
    Key? key,
    required this.paket,
    required this.alamat,
  }) : super(key: key);

  // Fungsi untuk menghitung tanggal akhir berdasarkan tanggal mulai dan durasi
  String _calculateEndDate(String startDate, int duration) {
    try {
      final dateFormat = DateFormat('yyyy-MM-dd');
      final start = dateFormat.parse(startDate);
      final end = start.add(Duration(days: duration));

      final outputFormat = DateFormat('d MMMM yyyy', 'id_ID');
      return outputFormat.format(end);
    } catch (e) {
      return 'Invalid date format';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMMM yyyy', 'id_ID');
    final startDateFormatted = dateFormat.format(DateFormat('yyyy-MM-dd').parse(alamat.date));
    final endDate = _calculateEndDate(alamat.date, paket.duration);

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
                              "Detail Pemesanan",
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
                                alamat.address,
                                style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        onEdit: () {
                          // fungsi edit untuk tombol ubah jika diperlukan
                        },
                      ),
                      const SizedBox(height: 10),
                      _buildSection(
                        title: "Tanggal dan Jam",
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Mulai dari tanggal: $startDateFormatted",
                              style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                            ),
                            Text(
                              "Hingga tanggal: $endDate",
                              style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                            ),
                            Text(
                              "Setiap Jam: ${alamat.time}",
                              style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                            ),
                          ],
                        ),
                        onEdit: () {
                          // fungsi edit untuk tombol ubah jika diperlukan
                        },
                      ),
                      const SizedBox(height: 10),
                      _buildSection(
                        title: "Informasi Paket",
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Harga Paket: Rp${paket.price}",
                              style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                            ),
                            Text(
                              "Masa Berlaku Paket: ${paket.duration} hari",
                              style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                            ),
                          ],
                        ),
                        onEdit: () {
                          // fungsi edit untuk tombol ubah jika diperlukan
                        },
                      ),
                      const SizedBox(height: 10),
                      _buildSection(
                        title: "Metode pembayaran",
                        content: Row(
                          children: [
                            Consumer<DanaProvider>(
                              builder: (context, danaProvider, child) {
                                return Text(
                                  danaProvider.metodePembayaran, // Ini akan menampilkan metode pembayaran yang ada di provider
                                  style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
                                );
                              },
                            ),
                            const Spacer(),
                            Consumer<DanaProvider>(
                              builder: (context, danaProvider, child) {
                                return Text(
                                  "Rp${danaProvider.jumlahDana.toStringAsFixed(0)}", // Ini menampilkan jumlah dana yang sudah dikurangi
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
                          // fungsi edit untuk tombol ubah jika diperlukan
                        },
                      ),

                      const SizedBox(height: 10),
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
                          Text(
                            "Rp${paket.price}",
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
  onPressed: () async {
    final totalHarga = paket.price;  // Mengambil harga dari paket

    // Periksa apakah jumlah dana cukup
    if (totalHarga <= context.read<DanaProvider>().jumlahDana) {
      // Mengurangi jumlah dana dengan harga total
      context.read<DanaProvider>().kurangiDana(totalHarga);

      // Setelah dana dikurangi, lanjutkan ke pembayaran
      final apiLangganan = ApiLangganan();
      final response = await apiLangganan.createSubscription(paket, alamat);

      if (response.containsKey('error')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['error'])),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PinInputScreen(
              paket: paket,
              alamat: alamat,
            ),
          ),
        );

      }
    } else {
      // Jika saldo tidak cukup
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Saldo tidak cukup untuk melanjutkan pembayaran")),
      );
    }
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

                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ],
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
  final PaketModel paket;
  final AlamatModel alamat;
  

  const PinInputScreen({
    Key? key,
    required this.paket,
    required this.alamat,
    
  }) : super(key: key);

  @override
  _PinInputScreenState createState() => _PinInputScreenState();
}

class _PinInputScreenState extends State<PinInputScreen> {
  final int pinLength = 6;
  String inputPin = "";

 // Fungsi untuk menghitung tanggal akhir berdasarkan tanggal mulai dan durasi
  String _calculateEndDate(String startDate, int duration) {
    try {
      final dateFormat = DateFormat('yyyy-MM-dd');
      final start = dateFormat.parse(startDate);
      final end = start.add(Duration(days: duration));

      final outputFormat = DateFormat('d MMMM yyyy', 'id_ID');
      return outputFormat.format(end);
    } catch (e) {
      return 'Invalid date format';
    }
  }

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
  
  // Modify PinInputScreen in pemesanannantipidetail.dart to save the active package
void _onConfirm() {
    if (inputPin.length == pinLength) {
      // Create active package
      final activePaket = ActivePaketModel(
        name: widget.paket.name,
        price: widget.paket.price,
        duration: widget.paket.duration,
        startDate: widget.alamat.date,
        endDate: _calculateEndDate(widget.alamat.date, widget.paket.duration),
        address: widget.alamat.address,
      );
      
      // Save to provider
      Provider.of<ActivePaketProvider>(context, listen: false)
          .addActivePaket(activePaket);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("PIN berhasil: $inputPin")),
      );
      Navigator.of(context).pop(true);
      Navigator.pushReplacementNamed(context, '/home');
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
              // if (inputPin.length == pinLength) {
              //   Navigator.pushNamed(context, '/home');
              // }
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


