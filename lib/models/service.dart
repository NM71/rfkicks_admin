class Service {
  final int id;
  final String name;
  final double price;
  final String imagePath;
  final String description;
  final String serviceType;

  Service({
    required this.id,
    required this.name,
    required this.price,
    required this.imagePath,
    required this.description,
    required this.serviceType,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      name: json['name'],
      price: double.parse(json['price'].toString()),
      imagePath: json['image_path'],
      description: json['description'] ?? '',
      serviceType: json['service_type'],
    );
  }
}