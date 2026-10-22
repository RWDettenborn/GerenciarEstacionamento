class ParkingSpot {
  final String? id;
  final String parkingSpotNumber;
  final String licensePlateCar;
  final String brandCar;
  final String modelCar;
  final String colorCar;
  final String? registrationDate;
  final String responsibleName;
  final String apartment;
  final String block;

  ParkingSpot({
    this.id,
    required this.parkingSpotNumber,
    required this.licensePlateCar,
    required this.brandCar,
    required this.modelCar,
    required this.colorCar,
    this.registrationDate,
    required this.responsibleName,
    required this.apartment,
    required this.block,
  });

  factory ParkingSpot.fromJson(Map<String, dynamic> json) {
    return ParkingSpot(
      id: json['id']?.toString(),
      parkingSpotNumber: (json['parkingSpotNumber'] ?? '').toString(),
      licensePlateCar: (json['licensePlateCar'] ?? '').toString(),
      brandCar: (json['brandCar'] ?? '').toString(),
      modelCar: (json['modelCar'] ?? '').toString(),
      colorCar: (json['colorCar'] ?? '').toString(),
      registrationDate: json['registrationDate']?.toString(),
      responsibleName: (json['responsibleName'] ?? '').toString(),
      apartment: (json['apartment'] ?? '').toString(),
      block: (json['block'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'parkingSpotNumber': parkingSpotNumber,
      'licensePlateCar': licensePlateCar,
      'brandCar': brandCar,
      'modelCar': modelCar,
      'colorCar': colorCar,
      'responsibleName': responsibleName,
      'apartment': apartment,
      'block': block,
    };
  }
}
