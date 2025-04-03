import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rfkicks_admin/views/admin_orders_screen.dart';

class AdminOrderDetailsScreen extends StatelessWidget {
  final Order order;

  const AdminOrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Order #${order.id}'),
        centerTitle: true,
        backgroundColor: Colors.white.withOpacity(0.1),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(
              'Customer Information',
              [
                _buildInfoRow(
                    'Customer ID', order.customerId?.toString() ?? 'N/A'),
                _buildInfoRow('Email', order.billingEmail ?? 'N/A'),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              'Order Information',
              [
                _buildInfoRow('Status', order.status?.toUpperCase() ?? 'N/A'),
                _buildInfoRow(
                  'Date',
                  // DateFormat('yyyy-MM-dd HH:mm').format(order.dateCreated),
                  DateFormat('MMMM d, y, h:mm a').format(order.dateCreated),
                ),
                _buildInfoRow('Total Amount',
                    '${order.currency?.toUpperCase() ?? ''} ${order.totalAmount}'),
                _buildInfoRow('Payment Method',
                    order.paymentMethodTitle?.toUpperCase() ?? 'N/A'),
                _buildInfoRow('Delivery Type', order.deliveryType ?? ''),
                _buildInfoRow('Transaction ID', order.transactionId ?? 'N/A'),
              ],
            ),
            const SizedBox(height: 16),
            _buildServicesSection(),
            const SizedBox(height: 16),
            _buildAddressSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    if (order.address == null) return const SizedBox.shrink();

    return _buildInfoCard(
      'Delivery Address',
      [
        _buildInfoRow('Name',
            '${order.address?.firstName ?? ''} ${order.address?.lastName ?? ''}'),
        _buildInfoRow('Address', order.address?.address1 ?? ''),
        if (order.address?.address2?.isNotEmpty ?? false)
          _buildInfoRow('Address 2', order.address?.address2 ?? ''),
        _buildInfoRow('City', order.address?.city ?? ''),
        _buildInfoRow('State', order.address?.state ?? ''),
        _buildInfoRow('Postcode', order.address?.postcode ?? ''),
        _buildInfoRow('Country', order.address?.country ?? ''),
        _buildInfoRow('Phone', order.address?.phone ?? ''),
      ],
    );
  }

  // Services Ordered Details
  Widget _buildServicesSection() {
    return _buildInfoCard(
      'Ordered Services',
      [
        ...order.items
            .map((item) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.serviceName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Text(
                          '${item.quantity}x \$${item.price.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                    if (item.serviceDescription != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.serviceDescription!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                    const Divider(),
                  ],
                ))
            .toList(),
      ],
    );
  }
}
