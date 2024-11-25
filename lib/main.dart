import 'package:flutter/material.dart';
import 'terms.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      fontFamily: 'Poppins', // Set default font to Poppins
    ),
    home: OnboardingScreen(),
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

  void _nextPage() {
  if (_currentPage < 3) {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  } else {
    // Navigate to the Terms and Conditions screen when onboarding completes
    Navigator.push(
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
                  margin: const EdgeInsets.only(top: 24.0), // Adjusted spacing with margin
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
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

  // Method to build each onboarding page
  Widget _buildPage({required Widget image, required String title, required String description, required int activeIndex}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0), // Padding used for spacing
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          image,
          Padding(
            padding: const EdgeInsets.only(top: 24.0), // Adjusted spacing with padding
            child: title.isNotEmpty
                ? Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26, // Adjusted font size for title
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  )
                : SizedBox.shrink(), // Avoid using unnecessary SizedBox
          ),
          if (title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16.0), // Adjusted spacing with padding
            ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0), // Adjusted spacing with padding
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16, // Adjusted font size for description
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
