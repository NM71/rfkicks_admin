class OrderItem {
  final int serviceId;
  final String serviceName;
  final int quantity;
  final double price;
  final String? serviceDescription;

  OrderItem({
    required this.serviceId,
    required this.serviceName,
    required this.quantity,
    required this.price,
    this.serviceDescription,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      serviceId: json['service_id'],
      serviceName: json['service_name'],
      quantity: json['quantity'],
      price: double.parse(json['price'].toString()),
      serviceDescription: json['service_description'],
    );
  }
}
