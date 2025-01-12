class InputInstanModel {
  final String address; // Alamat input
  final String vehicle; // Jenis kendaraan yang dipilih
  final String weightEstimate; // Estimasi berat
  final double lat; // Latitude dari alamat yang dimasukkan
  final double lng; // Longitude dari alamat yang dimasukkan
  final double price; // Harga yang dihitung berdasarkan jarak dan kendaraan

  InputInstanModel({
    required this.address,
    required this.vehicle,
    required this.weightEstimate,
    required this.lat,
    required this.lng,
    required this.price,
  });

  // Konversi model menjadi Map untuk pengiriman ke API atau penyimpanan lokal
  Map<String, dynamic> toMap() {
    return {
      'address': address,
      'vehicle': vehicle,
      'weightEstimate': weightEstimate,
      'lat': lat,
      'lng': lng,
      'price': price,
    };
  }

  // Membaca data dari Map (misalnya, saat mengambil data dari API atau database)
  factory InputInstanModel.fromMap(Map<String, dynamic> map) {
    return InputInstanModel(
      address: map['address'] ?? '',
      vehicle: map['vehicle'] ?? '',
      weightEstimate: map['weightEstimate'] ?? '',
      lat: map['lat'] ?? 0.0,
      lng: map['lng'] ?? 0.0,
      price: map['price'] ?? 0.0,
    );
  }
}
