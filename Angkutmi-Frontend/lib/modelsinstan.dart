class InputInstanModel {
  final String address; // Alamat input
  final String vehicle; // Jenis kendaraan yang dipilih
  final String weightEstimate; // Estimasi berat

  InputInstanModel({
    required this.address,
    required this.vehicle,
    required this.weightEstimate,
  });

  Map<String, dynamic> toMap() {
    return {
      'address': address,
      'vehicle': vehicle,
      'weightEstimate': weightEstimate,
    };
  }

  factory InputInstanModel.fromMap(Map<String, dynamic> map) {
    return InputInstanModel(
      address: map['address'] ?? '',
      vehicle: map['vehicle'] ?? '',
      weightEstimate: map['weightEstimate'] ?? '',
    );
  }
}
