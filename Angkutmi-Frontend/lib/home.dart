import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'pemesanannantipi.dart';
import 'service/coupon_service.dart';
import 'mapsinstan.dart';

import 'gacha.dart';
import 'track_order.dart';

// Main entry point for the app
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String userName = ''; // Variable to store the user name

  final _storage = const FlutterSecureStorage();

  // Function to fetch the user name from secure storage
  Future<void> _getUserName() async {
    final String? name = await _storage.read(key: 'user_name');
    if (name != null) {
      setState(() {
        userName = name; // Update the state with the user name
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserName(); // Fetch the user name when the app starts
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Poppins'),
      home: userName.isEmpty
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator while fetching
          : HomeScreen(userName: userName), // Pass the user name after it's fetched
    );
  }
}


// HomeScreen to display the main content
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required userName});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String userName = '';
  
  final _storage = const FlutterSecureStorage();

  // Function to fetch the user name from secure storage
  Future<void> _getUserName() async {
    final String? name = await _storage.read(key: 'user_name');
    if (name != null) {
      setState(() {
        userName = name;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserName(); // Fetch the user name when the screen is initialized
  }

  final List<Widget> _pages = const [
    HomeContent(userName: '',),
    VoucherPage(),
    ProfileScreen(userName: '',),
  ];

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Image.asset(
          'assets/home/logoAngkutmi.png',
          width: 125,
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 44, 158, 75),
    ),
    backgroundColor: const Color.fromARGB(255, 44, 158, 75),
    body: IndexedStack(
      index: _selectedIndex, // Display the page corresponding to _selectedIndex
      children: [
        HomeContent(userName: userName), // Home page
        const VoucherPage(), // Voucher page
        ProfileScreen(userName: userName), // Profile page
      ],
    ),
    bottomNavigationBar: BottomNavigationBar(
      backgroundColor: Colors.white,
      selectedItemColor: const Color.fromARGB(255, 44, 158, 75),
      unselectedItemColor: Colors.grey,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_activity),
          label: 'Rewards',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          label: 'Profile',
        ),
      ],
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index; // Update the selected index
        });
      },
    ),
  );
}
  }

// HomeContent Widget to display the greeting and services
class HomeContent extends StatelessWidget {
  final String userName;

  const HomeContent({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(left: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Image.asset(
                  'assets/home/orang.png',
                  height: 193,
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Selamat Datang, \n$userName !', // Display dynamic userName
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19.0,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10, right: 30, left: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'Task harian',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: const LinearProgressIndicator(
                              value: 0.48,
                              backgroundColor: Color.fromARGB(255, 255, 242, 178),
                              valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 158, 215, 99)),
                              minHeight: 10.0,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(
                                children: <Widget>[ 
                                  const Padding(
                                    padding: EdgeInsets.only(right: 3.0),
                                    child: Text(
                                      '5',
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 255, 242, 178),
                                        fontSize: 15.0,
                                      ),
                                    ),
                                  ),
                                  SvgPicture.asset('assets/home/poin.svg', height: 15),
                                ],
                              ),
                              const Text(
                                '48%',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 255, 242, 178),
                                  fontSize: 15.0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(66.0),
                topRight: Radius.circular(66.0),
              ),
            ),
            child: Column(
              children: <Widget>[
                const Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 30.0, top: 30),
                    child: Text(
                      'Layanan',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24.0,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MapsInstan(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 3,
                            backgroundColor: const Color.fromARGB(255, 44, 158, 75),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SvgPicture.asset('assets/home/trash.svg', fit: BoxFit.cover, width: 60),
                              const Text(
                                'Angkutmi',
                                style: TextStyle(fontSize: 13, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PemesananNantipi(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 3,
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SvgPicture.asset('assets/home/nantipi.svg', fit: BoxFit.cover, width: 60),
                              const Text(
                                'Nantipi',
                                style: TextStyle(fontSize: 13, color: Color.fromARGB(255, 44, 158, 75)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 60),
                  height: 150,
                  width: 300,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 115, 115, 115),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(' '),
                  ),
                ),

              // THIS BUTTON IS TEMPORARY
              // ==============================================================
              Container(
                margin: const EdgeInsets.only(top: 20),
                height: 50,
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderTrackingScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 44, 158, 75),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Track Order',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              // ==============================================================

              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ProfileScreen extends StatelessWidget {
  final String userName;

  const ProfileScreen({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              painter: HeaderCurvedContainer(),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 40.0, bottom: 30),
                  child: Text(
                    'Profile anda',
                    style: TextStyle(
                      fontSize: 30.0,
                      letterSpacing: 1.5,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,

                    ),
                  ),       
                  ),
                  CircleAvatar(
                  radius: MediaQuery.of(context).size.width / 5,
                  backgroundColor: Colors.white,
                  // backgroundImage: SvgPicture.asset('assets/home/user-circle.png'),       
                child: SvgPicture.asset(
                  'assets/home/user-circle.svg',
                ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Align left
                    children: [
                      Container(

                        // decoration: BoxDecoration(
                        //   border: Border.all(color: Colors.black),
                        //   borderRadius: BorderRadius.circular(5),
                        // ),
                        padding: const EdgeInsets.only(right: 10.0,top: 10.0,bottom: 5.0),
                        child: const Text(
                          'Nama Lengkap',
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 20.0,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class HeaderCurvedContainer extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromARGB(255, 44, 158, 75)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..lineTo(0, 0)
      ..lineTo(0, size.height * 0.35)
      ..quadraticBezierTo(
          size.width * 0.5, size.height * 0.50, size.width, size.height * 0.35)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}


// VoucherPage Widget

class VoucherPage extends StatefulWidget {
  const VoucherPage({super.key});

  @override
  _VoucherPageState createState() => _VoucherPageState();
}

class _VoucherPageState extends State<VoucherPage> {
  final List<String> _vouchers = []; // List to store claimed vouchers
  bool _isLoading = true; // Loading indicator state
  final CouponService couponService = CouponService(baseUrl: 'http://127.0.0.1:8000/api');

  @override
  void initState() {
    super.initState();
    _fetchVouchers(); // Fetch claimed vouchers when the page is loaded
  }

  // Fetch the list of claimed vouchers from the backend
  Future<void> _fetchVouchers() async {
    try {
      final vouchers = await couponService.fetchClaimedCoupons(); // Fetch claimed coupons
      setState(() {
        _vouchers.addAll(vouchers); // Add the fetched claimed vouchers to the list
        _isLoading = false; // Update loading state
      });
    } catch (e) {
      setState(() {
        _isLoading = false; // Update loading state in case of an error
      });
      print('Error: $e');
    }
  }

  void _navigateToFortuneWheelPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ExamplePage()),
    );
  }

  // Method to add a test voucher manually (for testing)
  void _addVoucher() {
    setState(() {
      _vouchers.add("Voucher #${_vouchers.length + 1}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 44, 158, 75),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(66.0),
            topRight: Radius.circular(66.0),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: ElevatedButton(
                onPressed: _navigateToFortuneWheelPage,
                style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text("Go to Fortune Wheel"),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 15, bottom: 20),
              child: Text(
                "Voucher anda",
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _vouchers.isEmpty
                      ? const Center(
                          child: Text(
                            "Belum ada voucher",
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _vouchers.length,
                          itemBuilder: (context, index) {
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 30),
                              color: Colors.white,
                              elevation: 3,
                              child: ListTile(
                                leading: const Icon(
                                  Icons.local_cafe,
                                  color: Colors.grey,
                                  size: 40,
                                ),
                                title: Text(_vouchers[index]),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 25),
                              ),
                            );
                          },
                        ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: ElevatedButton(
                onPressed: _addVoucher, // Add test voucher manually for testing
                style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text("tes tambah"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
