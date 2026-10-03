class PassengerInfo {
  final String passengerId;
  final String name;
  final String phone;
  final List<int> seatNumbers;
  final String? paymentMethod; // New: Track payment method per passenger
  final bool paid; // New: Track payment status per passenger

  PassengerInfo({
    required this.passengerId,
    required this.name,
    required this.phone,
    required this.seatNumbers,
    this.paymentMethod,
    this.paid = false,
  });

  Map<String, dynamic> toJson() => {
    'passengerId': passengerId,
    'name': name,
    'phone': phone,
    'seatNumbers': seatNumbers,
    'paymentMethod': paymentMethod,
    'paid': paid,
  };

  factory PassengerInfo.fromJson(Map<String, dynamic> json) => PassengerInfo(
    passengerId: json['passengerId'] ?? '',
    name: json['name'] ?? '',
    phone: json['phone'] ?? '',
    seatNumbers: json['seatNumbers'] != null
        ? List<int>.from(json['seatNumbers'])
        : [],
    paymentMethod: json['paymentMethod'],
    paid: json['paid'] ?? false,
  );
}