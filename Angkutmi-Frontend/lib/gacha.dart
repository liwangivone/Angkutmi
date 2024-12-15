import 'dart:async';
import 'dart:convert';
// import 'dart:math';
import 'package:http/http.dart' as http; // temporary.. maybe..
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  _ExamplePageState createState() => _ExamplePageState();
}

class Rewards {
  final String hadiah;
  var img;

  Rewards({required this.hadiah, this.img});

  factory Rewards.fromJson(Map<String, dynamic> json) {
    return Rewards(hadiah: json['strMeal'], img: json['strMealThumb']);
  }
}

class _ExamplePageState extends State<ExamplePage> {
  StreamController<int> selected = StreamController<int>();

  String url = "https://www.themealdb.com/api/json/v1/1/filter.php?a=Indian";
  List<Rewards> _ideas = [];

  Future<void> _getLunchIdeas() async {
    http.Response response;

    Uri uri = Uri.parse(url);
    response = await http.get(uri);

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = json.decode(response.body);

      if (jsonData['meals'] != null) {
        List<dynamic> meals = jsonData['meals'];
        setState(() {
          _ideas = meals.map((json) => Rewards.fromJson(json)).toList();
          _ideas.shuffle(); // Randomize the order of lunch ideas
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getLunchIdeas();
  }

  @override
  void dispose() {
    selected.close();
    super.dispose();
  }

  var selectedIdea = "";
  late var selectedImg;
  void setValue(value) {
    selectedIdea = _ideas[value].hadiah.toString();
    selectedImg = _ideas[value].img;
  }

  @override
  Widget build(BuildContext context) {
    var flag = false;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Roda Keberuntungan'),
        backgroundColor: const Color.fromARGB(255, 44, 158, 75),
      ),
      backgroundColor: const Color.fromARGB(255, 44, 158, 75), // Changed background color to green
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white, // Changed container background color to white
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(66.0),
            topRight: Radius.circular(66.0),
          ),
        ),
        child: _ideas.length > 2
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  children: [
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selected.add(
                              Fortune.randomInt(0, _ideas.length),
                            );
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green, // Make button green
                        ),
                        child: const Text("Spin the Wheel"),
                      ),
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: MediaQuery.of(context).size.height / 2,
                              child: FortuneWheel(
                                selected: selected.stream,
                                items: [
                                  for (var it in _ideas)
                                    FortuneItem(child: Text(it.hadiah)),
                                ],
                                onAnimationEnd: () {
                                  showDialog(
                                      barrierDismissible: true,
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Center(
                                          child: AlertDialog(
                                            scrollable: true,
                                            title: const Text("Selamat! anda mendapatkan"),
                                            content: Column(
                                              children: [
                                                const SizedBox(height: 10),
                                                Text(
                                                  selectedIdea,
                                                  style: const TextStyle(fontSize: 22),
                                                ),
                                                const SizedBox(height: 20),
                                                Image.network(selectedImg),
                                              ],
                                            ),
                                          ),
                                        );
                                      });
                                },
                                onFocusItemChanged: (value) {
                                  if (flag == true) {
                                    setValue(value);
                                  } else {
                                    flag = true;
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : const Center(
                child: CircularProgressIndicator(color: Colors.green),
              ),
      ),
    );
  }
}
