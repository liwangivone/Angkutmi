import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart'; // menggunakan SVG logo.
import 'regis_login.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
                      children: [
                        // Logo di bagian kiri atas
                        Image.asset(
                          'assets/home/logoAngkutmi.png', 
                          width: 125,
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
          // Konten Utama
          Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 0, bottom: 15),
                    child: Text(
                      "Syarat dan Ketentuan",
                      style: TextStyle(
                        fontSize: 21,
                        letterSpacing: 2,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: const Text(
                        '1. Pengguna wajib membaca dan memahami syarat dan ketentuan ini sebelum menggunakan layanan Angkutmi.\n'
                        '2. Dengan menggunakan aplikasi Angkutmi, pengguna dianggap telah menyetujui seluruh syarat dan ketentuan ini.\n'
                        '3. Angkutmi hanya melayani wilayah operasional yang telah ditentukan dan tertera dalam aplikasi.\n'
                        '4. Layanan pengangkutan hanya berlaku untuk jenis sampah yang sesuai dengan ketentuan Angkutmi (domestik/non-B3).\n'
                        '5. Pengguna bertanggung jawab untuk memastikan sampah telah dikemas dengan aman dan tidak menimbulkan bahaya bagi pengangkut.\n'
                        '6. Angkutmi tidak menerima sampah berbahaya (B3), termasuk limbah medis, bahan kimia, atau bahan peledak.\n'
                        '7. Pengguna wajib menyediakan informasi lokasi yang akurat saat melakukan pemesanan layanan.\n'
                        '8. Setiap kesalahan informasi yang mengakibatkan kegagalan layanan menjadi tanggung jawab pengguna.\n'
                        '9. Angkutmi berhak membatalkan layanan jika lokasi tidak dapat diakses oleh kendaraan operasional.\n'
                        '10. Layanan hanya akan diproses setelah pembayaran sesuai metode yang tersedia di aplikasi.\n'
                        '11. Pengguna tidak diperbolehkan membayar langsung kepada petugas lapangan kecuali diinstruksikan oleh aplikasi.\n'
                        '12. Biaya layanan dihitung berdasarkan jumlah sampah dan jarak lokasi yang tertera pada aplikasi.\n'
                        '13. Angkutmi berhak mengenakan biaya tambahan untuk layanan khusus di luar ketentuan standar.\n'
                        '14. Pembatalan layanan oleh pengguna setelah proses pengangkutan dimulai akan dikenakan biaya administrasi.\n'
                        '15. Angkutmi tidak bertanggung jawab atas kehilangan atau kerusakan barang yang tercampur dengan sampah.\n'
                        '16. Pengguna wajib memastikan bahwa sampah tidak mengandung barang berharga.\n'
                        '17. Data pribadi pengguna akan disimpan dan digunakan sesuai dengan kebijakan privasi Angkutmi.\n'
                        '18. Angkutmi tidak membagikan data pengguna kepada pihak ketiga tanpa persetujuan pengguna.\n'
                        '19. Waktu layanan yang tertera pada aplikasi bersifat estimasi dan dapat berubah karena kondisi lapangan.\n'
                        '20. Pengguna wajib memberikan penilaian atau ulasan yang jujur sesuai pengalaman layanan.\n'
                        '21. Angkutmi berhak menangguhkan atau menonaktifkan akun pengguna yang melanggar syarat dan ketentuan.\n'
                        '22. Angkutmi berhak memperbarui syarat dan ketentuan ini sewaktu-waktu tanpa pemberitahuan sebelumnya.\n'
                        '23. Pengguna bertanggung jawab untuk memperbarui aplikasi agar tetap dapat menggunakan layanan.\n'
                        '24. Kerusakan lingkungan atau dampak lain akibat kelalaian pengguna bukan tanggung jawab Angkutmi.\n'
                        '25. Pengguna dilarang menggunakan aplikasi Angkutmi untuk tujuan yang melanggar hukum.\n'
                        '26. Penyalahgunaan layanan untuk membuang sampah ilegal dapat dilaporkan kepada pihak berwenang.\n'
                        '27. Angkutmi memiliki hak penuh untuk menentukan jenis dan volume sampah yang dapat diterima.\n'
                        '28. Komunikasi resmi hanya melalui fitur aplikasi atau kontak yang disediakan oleh Angkutmi.\n'
                        '29. Segala perselisihan yang timbul akan diselesaikan berdasarkan hukum yang berlaku di wilayah operasional.\n'
                        '30. Pengguna dianggap setuju dengan syarat dan ketentuan ini dengan mengunduh atau menggunakan aplikasi Angkutmi.\n',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                            
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => RegistrationScreen()),
                            );
                          },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 44, 158, 75),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Setuju',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
