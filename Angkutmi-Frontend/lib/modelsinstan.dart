class InputInstanModel {
  final String address; // Alamat input
  final String vehicle; // Jenis kendaraan yang dipilih

  InputInstanModel({
    required this.address,
    required this.vehicle,
  });

  // Fungsi untuk mengubah data menjadi Map (misalnya untuk dikirim ke API)
  Map<String, dynamic> toMap() {
    return {
      'address': address,
      'vehicle': vehicle,
    };
  }

  // Fungsi untuk membuat model dari Map (misalnya dari API response)
  factory InputInstanModel.fromMap(Map<String, dynamic> map) {
    return InputInstanModel(
      address: map['address'] ?? '',
      vehicle: map['vehicle'] ?? '',
    );
  }
}
