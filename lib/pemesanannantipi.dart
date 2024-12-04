import 'package:flutter/material.dart';

class PemesananNantipi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 44, 158, 75),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            'Nantipi',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Column(
          children: [
            // Header hijau dengan lengkungan melengkung
            Stack(
              children: [
                Container(
                  height: 140,
                  color: const Color.fromARGB(255, 44, 158, 75),
                  
                ),
                // TabBar di tengah area hijau
                Positioned.fill(
                  top: 10,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: TabBar(
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.white70,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorColor: Colors.green,
                      indicator: const UnderlineTabIndicator(
                        borderSide: BorderSide(width: 2, color: Colors.black),
                        insets: EdgeInsets.symmetric(horizontal: 60.0),
                      ),
                      tabs: const [
                        Tab(child: Text('Paket',style: TextStyle(fontSize: 16),),),
                        
                        Tab(child: Text('Lagi aktif',style: TextStyle(fontSize: 16),),),
                      ],
                      onTap: (index) {},
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
            Expanded(
              child: TabBarView(
                children: [
                  PaketTab(),
                  Container(
                    color: Colors.white,
                      child: Center(
                        child: Text(
                        'Lagi aktif',
                        style: TextStyle(fontSize: 16),
                        )
                      ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class PaketTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // Tambahkan warna putih di Container luar
      child: ListView(
        padding: EdgeInsets.only(top: 5, bottom: 16.0, left: 16.0, right: 16.0),
        children: const [
          SubscriptionCard(
            title: 'Cobami dulu satu bulan',
            duration: 'Durasi: 1 bulan',
            price: 'Rp45.000',
          ),
          SubscriptionCard(
            title: 'Langsungmi tiga bulan',
            duration: 'Durasi: 3 bulan',
            price: 'Rp80.000',
          ),
          SubscriptionCard(
            title: 'Paling hematmi enam bulan',
            duration: 'Durasi: 6 bulan',
            price: 'Rp125.000',
          ),
        ],
      ),
    );
  }
}


class SubscriptionCard extends StatelessWidget {
  final String title;
  final String duration;
  final String price;

  const SubscriptionCard({
    Key? key,
    required this.title,
    required this.duration,
    required this.price,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      margin: EdgeInsets.only(bottom: 16,),
      color: Color(0xFFFFF2B2),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                duration,
                style: TextStyle(color: Colors.grey),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    price,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text('Beli'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
