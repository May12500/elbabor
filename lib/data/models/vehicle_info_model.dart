class VehicleInfo {
  final String brand;
  final String model;
  final String plate;
  final String? photoUrl;

  VehicleInfo({
    required this.brand,
    required this.model,
    required this.plate,
    this.photoUrl,
  });

  Map<String, dynamic> toJson() => {
    'brand': brand,
    'model': model,
    'plate': plate,
    'photoUrl': photoUrl,
  };

  factory VehicleInfo.fromJson(Map<String, dynamic> json) => VehicleInfo(
    brand: json['brand'] ?? '',
    model: json['model'] ?? '',
    plate: json['plate'] ?? '',
    photoUrl: json['photoUrl'],
  );

  static VehicleInfo empty() =>
      VehicleInfo(brand: '', model: '', plate: '', photoUrl: null);
}
