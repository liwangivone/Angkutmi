import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'pemesanannantipi.dart';
// import 'regis_login.dart';

// void main() {
//   runApp(const MyApp());
// }
//onboard nya sekali jalan jie kalau mw itu hrus di run ulang .. karena disini ada main jg .. kemungkinan

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Poppins'),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _pages = const [
    HomeContent(),
    VoucherPage(),
    ProfileScreen(),
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
      body: _pages[_selectedIndex],
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
            label: 'Voucher',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(
            left: 15.0,
          ),
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
                    const Text(
                      'Selamat Datang, \nIvone !',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19.0,
                        // fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      margin:
                          const EdgeInsets.only(top: 10, right: 30, left: 30),
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
                              backgroundColor:
                                  Color.fromARGB(255, 255, 242, 178),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Color.fromARGB(255, 158, 215, 99)),
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
                                        color:
                                            Color.fromARGB(255, 255, 242, 178),
                                        fontSize: 15.0,
                                      ),
                                    ),
                                  ),
                                  SvgPicture.asset('assets/home/poin.svg',
                                      height: 15),
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
                    padding: EdgeInsets.only(
                      left: 30.0,
                      top: 30,
                    ),
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
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            elevation: 3,
                            backgroundColor: const Color.fromARGB(
                                255, 44, 158, 75),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SvgPicture.asset('assets/home/trash.svg',
                                  fit: BoxFit.cover, width: 60),
                              const Text(
                                'Angkutmi',
                                style: TextStyle(
                                    fontSize: 13, color: Colors.white),
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
                                builder: (context) =>
                                    PemesananNantipi(),
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
                              SvgPicture.asset('assets/home/nantipi.svg',
                                  fit: BoxFit.cover, width: 60),
                              const Text(
                                'Nantipi',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Color.fromARGB(255, 44, 158, 75)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  // ini mau di ganti ke carousel nanti
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
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class VoucherPage extends StatefulWidget {
  const VoucherPage({super.key});

  @override
  _VoucherPageState createState() => _VoucherPageState();
}

class _VoucherPageState extends State<VoucherPage> {
  final List<String> _vouchers = [];

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
        // padding: const EdgeInsets.only(top: 20),
        // margin: EdgeInsets.only(top: 20),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(66.0),
                topRight: Radius.circular(66.0))),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 35, bottom: 20),
              child: Text(
                "Voucher anda",
                style: TextStyle(fontSize: 18, color: Colors.black,),
              ),
            ),
            Expanded(
              child: _vouchers.isEmpty
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
                onPressed: _addVoucher,
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


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: const Text("Profile Page"),
      ),
    );
  }
}

