import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:intl/intl.dart';
import 'home.dart';

class OrderTrackingScreen extends StatefulWidget {
  @override
  _OrderTrackingScreenState createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Timer _timer;
  late int _remainingTime;
  late int _totalTime; // Added to store initial time
  late String _currentDate;
  late String _orderNumber;
  bool isDriverReached = false;
  bool isAllCompleted = false;

  @override
  void initState() {
    super.initState();
    _generateOrderNumber();
    _generateRandomTime();
    _updateCurrentDate();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat();

    // Start timer
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
          
          // Check if we've reached halfway point
          if (_remainingTime <= (_totalTime * 19/20) && !isDriverReached) {
            isDriverReached = true;
          }
          
          // Check if timer has completed
          if (_remainingTime == 0) {
            isAllCompleted = true;
            _timer.cancel();
          }
        }
      });
    });
  }

  void _generateOrderNumber() {
    final random = Random();
    _orderNumber = (10000 + random.nextInt(900000)).toString();
  }

  void _generateRandomTime() {
    final random = Random();
    _remainingTime = 60 + random.nextInt(20 * 60 - 60);
    _totalTime = _remainingTime; // Store initial time
  }

  void _updateCurrentDate() {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE, d MMMM yyyy', 'id_ID');
    _currentDate = formatter.format(now);
  }

  String _formatRemainingTime() {
    final minutes = (_remainingTime / 60).floor();
    final seconds = _remainingTime % 60;
    return '$minutes menit ${seconds.toString().padLeft(2, '0')} detik';
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 44, 158, 75),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyApp())),
        ),
        title: Text(
          'Lacak pesanan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24, fontFamily: 'Poppins'),
        ),
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 44, 158, 75),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40.0),
                bottomRight: Radius.circular(40.0),
              ),
            ),
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentDate,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Nomor Pesanan: #$_orderNumber',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 60),
              child: Column(
                children: [
                  AnimatedTrackingStep(
                    label: 'Pesanan diterima',
                    isCompleted: true,
                    animation: _animationController,
                    isLast: false,
                  ),
                  AnimatedTrackingStep(
                    label: 'Driver sedang menuju lokasi',
                    isCompleted: isDriverReached,  // Will be completed at halfway point
                    animation: _animationController,
                    isLast: false,
                  ),
                  AnimatedTrackingStep(
                    label: 'Berhasil diangkut',
                    isCompleted: isAllCompleted,  // Will be completed when timer reaches 0
                    animation: _animationController,
                    isLast: true,
                  ),
                  Spacer(),
                  Text(
                    'Estimasi waktu: ${_formatRemainingTime()}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 30),
                  SizedBox(
                    height: 50,
                    width: 280,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => MyApp()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 44, 158, 75),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Kembali ke Beranda',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedTrackingStep extends StatelessWidget {
  final String label;
  final bool isCompleted;
  final AnimationController animation;
  final bool isLast;

  const AnimatedTrackingStep({
    required this.label,
    required this.isCompleted,
    required this.animation,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? Colors.green : Colors.grey.shade300,
              ),
              child: isCompleted
                  ? Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            if (!isLast)
              AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  return Container(
                    width: 2,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isCompleted
                            ? [
                                Colors.green,
                                Colors.green,
                                Colors.green.withOpacity(0.5),
                                Colors.green,
                              ]
                            : [
                                Colors.grey.shade300,
                                Colors.grey.shade300,
                              ],
                        stops: isCompleted
                            ? [0, animation.value, animation.value + 0.2, 1]
                            : [0, 1],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
        SizedBox(width: 20),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              label,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}