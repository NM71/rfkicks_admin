class ServiceAnalytics {
  final int id;
  final String name;
  final String serviceType;
  final int ordersCount;
  final double totalRevenue;
  final double averageRating;
  final int reviewsCount;
  final DateTime? lastOrderedAt;

  ServiceAnalytics({
    required this.id,
    required this.name,
    required this.serviceType,
    required this.ordersCount,
    required this.totalRevenue,
    required this.averageRating,
    required this.reviewsCount,
    this.lastOrderedAt,
  });

  factory ServiceAnalytics.fromJson(Map<String, dynamic> json) {
    return ServiceAnalytics(
      id: json['id'],
      name: json['name'],
      serviceType: json['service_type'],
      ordersCount: json['orders_count'],
      totalRevenue: double.parse(json['total_revenue'].toString()),
      averageRating: double.parse(json['average_rating'].toString()),
      reviewsCount: json['reviews_count'],
      lastOrderedAt: json['last_ordered_at'] != null
          ? DateTime.parse(json['last_ordered_at'])
          : null,
    );
  }
}
