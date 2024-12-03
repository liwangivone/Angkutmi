import 'package:flutter/material.dart';

class PemesananNantipi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
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
            // Bagian atas melengkung
            Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.15,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                ),
                Positioned.fill(
                  top: MediaQuery.of(context).size.height * 0.05,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: TabBar(
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.white70,
                      indicatorSize: TabBarIndicatorSize.tab, // Underline mengikuti lebar tab
                      indicatorColor: Colors.green!,
                      indicator: UnderlineTabIndicator(
                        borderSide: BorderSide(width: 2, color: Colors.black),
                        insets: EdgeInsets.symmetric(horizontal: 45.0), // Margin tetap nol
                      ),
                      tabs: [
                        Tab(text: 'Paket'),
                        Tab(text: 'Lagi aktif'),
                      ],
                       onTap: (index) {},
                    ),


                  ),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  PaketTab(),
                  Center(
                    child: Text(
                      'Lagi aktif',
                      style: TextStyle(fontSize: 16),
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
    return ListView(
      padding: EdgeInsets.all(16.0),
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
    );
  }
}

class SubscriptionCard extends StatelessWidget {
  final String title;
  final String duration;
  final String price;

  const SubscriptionCard({
    Key? key, // Tambahkan Key untuk lebih fleksibel.
    required this.title,
    required this.duration,
    required this.price,
  }) : super(key: key); 



  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      // Color: Color(value),
      elevation: 3,
      margin: EdgeInsets.only(bottom: 16),
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
