import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'terms.dart';
import 'package:intl/date_symbol_data_local.dart'; // Untuk inisialisasi data lokal

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi data format tanggal untuk locale Indonesia di waktu tertentu
  await initializeDateFormatting('id_ID', null);

  // Check if onboarding has been completed
  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      fontFamily: 'Poppins', // Set default font to Poppins
    ),
    home: hasSeenOnboarding ? TermsAndConditionsScreen() : OnboardingScreen(),
  ));
}

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Update the current page index
  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  // Handle "Lanjutkan" button
  Future<void> _nextPage() async {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Save onboarding completion status
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasSeenOnboarding', true);

      // Navigate to the Terms and Conditions screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TermsAndConditionsScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: [
                _buildPage(
                  image: Image.asset('assets/onboard/onboard1.png', height: 300),
                  title: 'Selamat datang\ndi Angkutmi !',
                  description: 'Sampah numpuk bikin risih, sini kita Angkutmi !',
                  activeIndex: 0,
                ),
                _buildPage(
                  image: Image.asset('assets/onboard/onboard2.png', height: 300),
                  title: '',
                  description: '"Mulai dari langkah kecil untuk menuju bumi yang lebih bersih"',
                  activeIndex: 1,
                ),
                _buildPage(
                  image: Image.asset('assets/onboard/onboard3.png', height: 300),
                  title: '',
                  description: '"Sampahmu punya potensi. Kami angkut, daur ulang, dan jaga bumi bersama"',
                  activeIndex: 2,
                ),
                _buildPage(
                  image: Image.asset('assets/onboard/onboard4.png', height: 300),
                  title: '',
                  description: '"Cepat, mudah, dan bisa \n diandalkan - Angkutmi solusinya!"',
                  activeIndex: 3,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Page Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    return _buildIndicator(isActive: _currentPage == index);
                  }),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 24.0),
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 44, 158, 75),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Lanjutkan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Method onboardbuild
  Widget _buildPage({required Widget image, required String title, required String description, required int activeIndex}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          image,
          Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: title.isNotEmpty
                ? Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  )
                : SizedBox.shrink(),
          ),
          if (title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Method to build the page indicator
  Widget _buildIndicator({bool isActive = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 12,
      width: 12,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green : Colors.grey.shade400,
        shape: BoxShape.circle,
      ),
    );
  }
}
