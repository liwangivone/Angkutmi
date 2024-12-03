import 'package:flutter/material.dart';
import 'regis_login.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:const Color.fromARGB(255, 44, 158, 75),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: const BoxDecoration(
              color: const Color.fromARGB(255, 44, 158, 75),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: const Center(
              child: Text(
                'Syarat dan Ketentuan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
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
                  // Navigate to registration/login screen when "Setuju" is pressed
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
    );
  }
}
