class Service {
  final int id;
  final String name;
  final double price;
  final String imagePath;
  final String? description;
  final String serviceType;
  final DateTime createdAt;
  final DateTime updatedAt;

  Service({
    required this.id,
    required this.name,
    required this.price,
    required this.imagePath,
    this.description,
    required this.serviceType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: int.parse(json['id'].toString()),
      name: json['name'],
      price: double.parse(json['price'].toString()),
      imagePath: json['image_path'],
      description: json['description'],
      serviceType: json['service_type'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image_path': imagePath,
      'description': description,
      'service_type': serviceType,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
