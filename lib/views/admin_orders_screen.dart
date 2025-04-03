import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rfkicks_admin/models/order_item_model.dart';
import 'package:rfkicks_admin/services/admin_api_service.dart';
import 'package:rfkicks_admin/views/admin_order_details_screen.dart';
import 'package:shimmer/shimmer.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  _AdminOrdersScreenState createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  late Future<List<Order>> _ordersFuture;
  String _searchQuery = '';
  String _statusFilter = 'All';
  List<Order> _filteredOrders = [];
  final TextEditingController _searchController = TextEditingController();

  final List<String> _statusOptions = [
    'All',
    'pending',
    'processing',
    'completed',
    'cancelled'
  ];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadOrders() {
    _ordersFuture = AdminApiService.getOrders();
    _ordersFuture.then((orders) {
      setState(() {
        _filteredOrders = List.from(orders);
      });
    });
  }

  void _filterOrders(List<Order> allOrders) {
    setState(() {
      _filteredOrders = allOrders.where((order) {
        // Search by order ID or email
        bool matchesSearch = order.id
                .toString()
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            (order.billingEmail ?? '')
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());

        // Filter by status
        bool matchesStatus = _statusFilter == 'All' ||
            (order.status ?? '').toLowerCase() == _statusFilter.toLowerCase();

        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Orders Management',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _loadOrders();
              });
            },
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // Shimmer Effect
  Widget _buildShimmerEffect() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[800]!,
          highlightColor: Colors.grey[600]!,
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: Colors.white.withOpacity(0.1),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 80,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 140,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 100,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleStatusUpdate(Order order) async {
    final String? newStatus = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        title: const Text('Update Order Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _statusOptions
              .where((status) => status != 'All')
              .map((status) => ListTile(
                    title: Text(status.toUpperCase()),
                    onTap: () => Navigator.pop(context, status),
                  ))
              .toList(),
        ),
      ),
    );

    if (newStatus != null && newStatus != order.status) {
      try {
        await AdminApiService.updateOrderStatus(order.id, newStatus);
        _loadOrders(); // Refresh the orders list
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order status updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update order status: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  opacity: 0.3,
                  image: AssetImage('assets/images/rfkicks_bg.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildFilters(),
                Expanded(
                  child: FutureBuilder<List<Order>>(
                    future: _ordersFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildShimmerEffect();
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error: ${snapshot.error}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }

                      if (_filteredOrders.isEmpty) {
                        return const Center(
                          child: Text(
                            'No orders found',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: _filteredOrders.length,
                        itemBuilder: (context, index) {
                          final order = _filteredOrders[index];
                          return _buildOrderCard(order);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      color: Colors.white.withOpacity(0.1),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search by Order ID or Email',
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white70),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                            _filterOrders(_filteredOrders);
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white30),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _ordersFuture.then((allOrders) {
                    _filterOrders(allOrders);
                  });
                });
              }),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white30),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                  value: _statusFilter,
                  isExpanded: true,
                  dropdownColor: Colors.black87,
                  style: const TextStyle(color: Colors.white),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  items: _statusOptions.map((String status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _statusFilter = newValue!;
                      _ordersFuture.then((allOrders) {
                        _filterOrders(allOrders);
                      });
                    });
                  }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    Color statusColor;
    switch (order.status?.toLowerCase()) {
      case 'completed':
        statusColor = Colors.green;
        break;
      case 'processing':
        statusColor = Colors.blue;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      case 'pending':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white.withOpacity(0.1),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(18),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Order #${order.id}',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
                border: Border.all(color: statusColor),
              ),
              child: Text(
                order.status?.toUpperCase() ?? 'N/A',
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              '${order.currency?.toUpperCase() ?? ''} ${order.totalAmount}',
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
            const SizedBox(height: 5),
            Text(
              // 'Date: ${DateFormat('yyyy-MM-dd HH:mm').format(order.dateCreated)}',
              DateFormat('MMMM d, y, h:mm a').format(order.dateCreated),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
            if (order.billingEmail != null) ...[
              const SizedBox(height: 5),
              Text(
                'Email: ${order.billingEmail}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(
                Icons.edit_note,
                color: Color(0xff3c76ad),
                size: 22,
              ),
              onPressed: () => _handleStatusUpdate(order),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(
                0xff3c76ad,
              ),
              size: 16,
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminOrderDetailsScreen(order: order),
            ),
          );
        },
      ),
    );
  }
}

// Orders Model (for orders screen)
class Order {
  final int id;
  final String? status;
  final String? currency;
  final String? type;
  final double totalAmount;
  final int? customerId;
  final String? billingEmail;
  final DateTime dateCreated;
  final String? paymentMethod;
  final String? paymentMethodTitle;
  final String? transactionId;
  final OrderAddress? address;
  final String? deliveryType;
  final List<OrderItem> items;

  Order({
    required this.id,
    this.status,
    this.currency,
    this.type,
    required this.totalAmount,
    this.customerId,
    this.billingEmail,
    required this.dateCreated,
    this.paymentMethod,
    this.paymentMethodTitle,
    this.transactionId,
    this.address,
    this.deliveryType,
    this.items = const [],
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: int.parse(json['id'].toString()),
      status: json['status'],
      currency: json['currency'],
      type: json['type'],
      totalAmount: double.parse(json['total_amount'].toString()),
      customerId: json['customer_id'] != null
          ? int.parse(json['customer_id'].toString())
          : null,
      billingEmail: json['billing_email'],
      dateCreated: DateTime.parse(
          json['date_created_gmt'] ?? DateTime.now().toIso8601String()),
      paymentMethod: json['payment_method'],
      paymentMethodTitle: json['payment_method_title'],
      transactionId: json['transaction_id'],
      address: json['address_1'] != null ? OrderAddress.fromJson(json) : null,
      deliveryType: json['delivery_type'] ?? 'Standard Delivery',
      items: (json['items'] as List?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class OrderAddress {
  final String? firstName;
  final String? lastName;
  final String? company;
  final String? address1;
  final String? address2;
  final String? city;
  final String? state;
  final String? postcode;
  final String? country;
  final String? email;
  final String? phone;

  OrderAddress({
    this.firstName,
    this.lastName,
    this.company,
    this.address1,
    this.address2,
    this.city,
    this.state,
    this.postcode,
    this.country,
    this.email,
    this.phone,
  });

  factory OrderAddress.fromJson(Map<String, dynamic> json) {
    return OrderAddress(
      firstName: json['first_name'],
      lastName: json['last_name'],
      company: json['company'],
      address1: json['address_1'],
      address2: json['address_2'],
      city: json['city'],
      state: json['state'],
      postcode: json['postcode'],
      country: json['country'],
      email: json['shipping_email'],
      phone: json['phone'],
    );
  }
}
