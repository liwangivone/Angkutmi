import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'regis_login.dart';
import 'home.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late TapGestureRecognizer _tapGestureRecognizer;
  bool _isPasswordVisible = false; // Mengontrol visibilitas password

  @override
  void initState() {
    super.initState();
    _tapGestureRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RegistrationScreen()),
        );
      };
  }

  @override
  void dispose() {
    _tapGestureRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mendapatkan ukuran layar untuk responsif
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.08, // Padding horizontal responsif
          vertical: screenHeight * 0.05, // Padding vertikal responsif
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: screenHeight * 0.05),
                    child: Text(
                      'Selamat datang kembali',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05, // Font size responsif
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: Image.asset(
                      'assets/onboard/onboard1.png',
                      height: screenHeight * 0.3, // Tinggi gambar responsif
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Nomor telepon',
                        labelStyle: const TextStyle(color: Colors.black),
                        hintText: '0895-xxx-xxx',
                        border: const UnderlineInputBorder(),
                        enabledBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey), // Warna border saat field tidak fokus
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.green,
                              width: 2.0), // Warna border saat field fokus
                        ),
                        errorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.red,
                              width: 1.0), // Warna border saat terjadi error
                        ),
                        focusedErrorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.red,
                              width: 1.0), // Warna border saat error dan field fokus
                        ),
                        suffixText: '*',
                        suffixStyle: const TextStyle(color: Colors.red),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nomor telepon tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible, // Mengontrol visibilitas password
                      decoration: InputDecoration(
                        labelText: 'Kata sandi',
                        labelStyle: const TextStyle(color: Colors.black),
                        border: const UnderlineInputBorder(),
                        enabledBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey), // Warna border saat field tidak fokus
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.green,
                              width: 2.0), // Warna border saat field fokus
                        ),
                        errorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.red,
                              width: 1.0), // Warna border saat terjadi error
                        ),
                        focusedErrorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.red,
                              width: 1.0), // Warna border saat error dan field fokus
                        ),
                        suffixText: '*',
                        suffixStyle: const TextStyle(color: Colors.red),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility // Ikon untuk menyembunyikan
                                : Icons.visibility_off, // Ikon untuk menampilkan
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Kata sandi tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0), // Padding atas tombol
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // login berhasil
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(),
                            ),
                          );

                          // Menampilkan notifikasi berhasil login
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Login berhasil!'),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Masuk',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: screenHeight * 0.02),
                child: Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'Belum memiliki akun? ',
                      style: TextStyle(color: Colors.black, fontSize: 14),
                      children: [
                        TextSpan(
                          text: 'Buat akun',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: _tapGestureRecognizer,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LoginScreen(),
  ));
}
