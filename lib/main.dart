import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(const MyApp());
}

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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Image.asset(
            'assets/home/logoAngkutmi.png', width: 125,
            // height: 30
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 44, 158, 75),
      ),
      backgroundColor: const Color.fromARGB(255, 44, 158, 75),
      body: Column(
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
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 30, right: 30, left: 30),
                        child: Column(
                          children: <Widget>[
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
                                  255, 44, 158, 75), // Changed background color
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
                            onPressed: () {},
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
                                      fontSize: 13, color: Color.fromARGB(255, 44, 158, 75)),
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
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white, // Changed background color to blue
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
      ),
    );
  }
}
