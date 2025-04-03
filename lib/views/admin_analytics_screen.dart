import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:rfkicks_admin/services/admin_api_service.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  _AdminAnalyticsScreenState createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic> _analyticsData = {};
  bool _isLoading = true;

  String formatRevenue(double value) {
    if (value >= 1000) {
      return '\$${(value / 1000).toStringAsFixed(1)}k';
    }
    return '\$${value.toStringAsFixed(2)}';
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAnalytics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalytics() async {
    try {
      final data = await AdminApiService.getServiceAnalytics();
      setState(() {
        _analyticsData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading analytics: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                if (!_isLoading) ...[
                  _buildTabBar(),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildOverviewTab(),
                        _buildServicesTab(),
                        _buildTrendsTab(),
                        _buildCustomersTab(),
                      ],
                    ),
                  ),
                ] else
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
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
                icon: const Icon(Icons.arrow_back_ios,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 8),
              const Text(
                'Business Analytics',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white.withOpacity(0.1),
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xff3c76ad),
        labelColor: Colors.white,
        tabs: const [
          Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
          Tab(icon: Icon(Icons.shopping_bag), text: 'Services'),
          Tab(icon: Icon(Icons.trending_up), text: 'Trends'),
          Tab(icon: Icon(Icons.people), text: 'Customers'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return RefreshIndicator(
      onRefresh: _loadAnalytics,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildOverviewCards(),
              const SizedBox(height: 20),
              _buildOrderStatusPieChart(),
              const SizedBox(height: 20),
              _buildRecentOrders(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCategoryComparison() {
    final services = _analyticsData['services'] as List? ?? [];
    final mainServices =
        services.where((s) => s['service_type'] == 'main').toList();
    final individualServices =
        services.where((s) => s['service_type'] == 'individual').toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Service Category Performance',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _buildCategoryStats('Main Services', mainServices)),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildCategoryStats(
                      'Individual Services', individualServices)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryStats(String title, List<dynamic> services) {
    final totalRevenue = services.fold(
        0.0,
        (sum, service) =>
            sum + double.parse(service['service_revenue'].toString()));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('${services.length} Services',
              style: const TextStyle(color: Colors.white70)),
          Text('\$${totalRevenue.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildRecentOrders() {
    final recentOrders = _analyticsData['recentOrders'] as List? ?? [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Orders',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...recentOrders.map((order) => _buildOrderItem(order)),
        ],
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> order) {
    final amount = double.parse(order['total_amount'].toString());
    final date = DateTime.parse(order['date_created_gmt']);

    return Card(
      color: Colors.white.withOpacity(0.1),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          'Order #${order['id']}',
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          DateFormat('MMM d, y HH:mm').format(date),
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${amount.toStringAsFixed(2)}',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(order['status']),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                order['status'] ?? '',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'processing':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildOrderStatusPieChart() {
    final recentOrders = _analyticsData['recentOrders'] as List? ?? [];
    final statusCount = {
      'pending': 0,
      'processing': 0,
      'completed': 0,
      'cancelled': 0,
    };

    for (var order in recentOrders) {
      final status = order['status']?.toString().toLowerCase() ?? '';
      if (statusCount.containsKey(status)) {
        statusCount[status] = statusCount[status]! + 1;
      }
    }

    return Container(
      height: 500,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Orders by Status',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          // Vertical Legend
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: statusCount.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _getStatusColor(entry.key),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${entry.key.toUpperCase()} (${entry.value})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 30),
          // Centered Pie Chart
          Expanded(
            child: Center(
              child: SizedBox(
                height: 280,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 50,
                    sections: statusCount.entries.map((entry) {
                      return PieChartSectionData(
                        color: _getStatusColor(entry.key),
                        value: entry.value.toDouble(),
                        title: entry.value.toString(),
                        radius: 110,
                        titleStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildOrderStatusPieChart() {
  //   final recentOrders = _analyticsData['recentOrders'] as List? ?? [];
  //   final statusCount = {
  //     'pending': 0,
  //     'processing': 0,
  //     'completed': 0,
  //     'cancelled': 0,
  //   };

  //   for (var order in recentOrders) {
  //     final status = order['status']?.toString().toLowerCase() ?? '';
  //     if (statusCount.containsKey(status)) {
  //       statusCount[status] = statusCount[status]! + 1;
  //     }
  //   }

  //   return Container(
  //     height: 300,
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: Colors.white.withOpacity(0.1),
  //       borderRadius: BorderRadius.circular(16),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const Text(
  //           'Orders by Status',
  //           style: TextStyle(
  //             color: Colors.white,
  //             fontSize: 18,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //         const SizedBox(height: 16),
  //         Expanded(
  //           child: PieChart(
  //             PieChartData(
  //               sectionsSpace: 2,
  //               centerSpaceRadius: 40,
  //               sections: _generatePieChartSections(statusCount),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  List<PieChartSectionData> _generatePieChartSections(
      Map<String, int> statusCount) {
    final colors = {
      'pending': Colors.orange,
      'processing': Colors.blue,
      'completed': Colors.green,
      'cancelled': Colors.red,
    };

    return statusCount.entries.map((entry) {
      return PieChartSectionData(
        color: colors[entry.key] ?? Colors.grey,
        value: entry.value.toDouble(),
        title: '${entry.key}\n${entry.value}',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildOverviewCards() {
    final formatter = NumberFormat.currency(symbol: '\$');
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildOverviewCard(
          'Total Revenue',
          formatter
              .format(double.parse(_analyticsData['totalRevenue'].toString())),
          Icons.attach_money,
          const Color(0xff3c76ad),
        ),
        _buildOverviewCard(
          'Total Orders',
          _analyticsData['totalOrders'].toString(),
          Icons.shopping_bag,
          const Color(0xff2c5582),
        ),
        _buildOverviewCard(
          'Total Customers',
          _analyticsData['totalCustomers'].toString(),
          Icons.people,
          const Color(0xff1e3d5c),
        ),
        _buildOverviewCard(
          'Services',
          (_analyticsData['services'] as List?)?.length.toString() ?? '0',
          Icons.design_services,
          const Color(0xff142943),
        ),
      ],
    );
  }

  Widget _buildOverviewCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildServicesTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildRevenueChart(),
            const SizedBox(height: 20),
            _buildServicePerformanceList(),
            const SizedBox(height: 20),
            _buildServiceCategoryComparison(),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart() {
    final services = _analyticsData['services'] as List? ?? [];
    return Container(
      height: 450, // Increased height for better visibility
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Revenue by Service',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Last 30 days performance',
                    style: TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.white70, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Tap bars for details',
                      style: TextStyle(color: Colors.white70, fontSize: 8),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: services.fold(
                        0.0,
                        (max, service) => double.parse(
                                    service['total_revenue'].toString()) >
                                max
                            ? double.parse(service['total_revenue'].toString())
                            : max) *
                    1.1,
                barGroups: services.asMap().entries.map((entry) {
                  final revenue =
                      double.parse(entry.value['total_revenue'].toString());
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: revenue,
                        color: const Color(0xff3c76ad),
                        width: 10,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6)),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: services.fold<double>(
                                  0.0,
                                  (max, service) => double.parse(
                                              service['total_revenue']
                                                  .toString()) >
                                          max
                                      ? double.parse(
                                          service['total_revenue'].toString())
                                      : max) *
                              1.1,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= services.length)
                          return const Text('');
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: RotatedBox(
                            quarterTurns: 1,
                            child: Text(
                              services[value.toInt()]['name'] ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      },
                      reservedSize: 60,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            formatRevenue(value),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                      reservedSize: 40,
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1000,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.white.withOpacity(0.1),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xff3c76ad),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Revenue',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServicePerformanceList() {
    final services = _analyticsData['services'] as List? ?? [];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Service Performance',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...services.map((service) => _buildServicePerformanceCard(service)),
        ],
      ),
    );
  }

  Widget _buildServicePerformanceCard(Map<String, dynamic> service) {
    final revenue = double.parse(service['total_revenue'].toString());
    final orders = int.parse(service['orders_count'].toString());

    return Card(
      color: Colors.white.withOpacity(0.05),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          service['name'] ?? '',
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Revenue: \$${(revenue)}',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              'Orders: $orders',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendsTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDailyRevenueChart(),
            const SizedBox(height: 20),
            _buildOrderTrendsChart(),
            const SizedBox(height: 20),
            _buildPopularTimesChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyRevenueChart() {
    final recentOrders = _analyticsData['recentOrders'] as List? ?? [];
    final dailyData = <DateTime, double>{};

    for (var order in recentOrders) {
      final date = DateTime.parse(order['date_created_gmt']);
      final amount = double.parse(order['total_amount'].toString());
      final key = DateTime(date.year, date.month, date.day);
      dailyData[key] = (dailyData[key] ?? 0) + amount;
    }

    final sortedDates = dailyData.keys.toList()..sort();
    final spots = sortedDates.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), dailyData[e.value]!);
    }).toList();

    return Container(
      height: 450,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Revenue',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1000,
                  getDrawingHorizontalLine: (value) {
                    return const FlLine(
                      color: Colors.white10,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= sortedDates.length) {
                          return const Text('');
                        }
                        final date = sortedDates[value.toInt()];
                        return Padding(
                          padding: const EdgeInsets.all(2),
                          child: Text(
                            DateFormat('MM/dd').format(date),
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          formatRevenue(value),
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 9),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: const Color(0xff3c76ad),
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xff3c76ad).withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildDailyRevenueChart() {
  //   final recentOrders = _analyticsData['recentOrders'] as List? ?? [];
  //   final dailyData = <DateTime, double>{};

  //   for (var order in recentOrders) {
  //     final date = DateTime.parse(order['date_created_gmt']);
  //     final amount = double.parse(order['total_amount'].toString());
  //     final key = DateTime(date.year, date.month, date.day);
  //     dailyData[key] = (dailyData[key] ?? 0) + amount;
  //   }

  //   final sortedDates = dailyData.keys.toList()..sort();
  //   final spots = sortedDates.asMap().entries.map((e) {
  //     return FlSpot(e.key.toDouble(), dailyData[e.value]!);
  //   }).toList();

  //   return Container(
  //     height: 450,
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: Colors.white.withOpacity(0.1),
  //       borderRadius: BorderRadius.circular(6),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const Text(
  //           'Daily Revenue',
  //           style: TextStyle(
  //             color: Colors.white,
  //             fontSize: 18,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //         const SizedBox(
  //           height: 30,
  //         ),
  //         Expanded(
  //           child: LineChart(
  //             LineChartData(
  //               gridData: FlGridData(
  //                 show: true,
  //                 drawVerticalLine: false,
  //                 horizontalInterval: 1000,
  //                 getDrawingHorizontalLine: (value) {
  //                   return const FlLine(
  //                     color: Colors.white10,
  //                     strokeWidth: 1,
  //                   );
  //                 },
  //               ),
  //               titlesData: FlTitlesData(
  //                 bottomTitles: AxisTitles(
  //                   sideTitles: SideTitles(
  //                     showTitles: true,
  //                     getTitlesWidget: (value, meta) {
  //                       if (value.toInt() >= sortedDates.length) {
  //                         return const Text('');
  //                       }
  //                       final date = sortedDates[value.toInt()];
  //                       return Padding(
  //                         padding: const EdgeInsets.all(2),
  //                         child: Text(
  //                           DateFormat('MM/dd').format(date),
  //                           style: const TextStyle(
  //                               color: Colors.white70, fontSize: 10),
  //                         ),
  //                       );
  //                     },
  //                   ),
  //                 ),
  //                 leftTitles: AxisTitles(
  //                   sideTitles: SideTitles(
  //                     showTitles: true,
  //                     getTitlesWidget: (value, meta) {
  //                       return Text(
  //                         '\$${value.toInt()}',
  //                         style: const TextStyle(
  //                             color: Colors.white70, fontSize: 10),
  //                       );
  //                     },
  //                   ),
  //                 ),
  //                 rightTitles: const AxisTitles(
  //                     sideTitles: SideTitles(showTitles: false)),
  //                 topTitles: const AxisTitles(
  //                     sideTitles: SideTitles(showTitles: false)),
  //               ),
  //               borderData: FlBorderData(show: false),
  //               lineBarsData: [
  //                 LineChartBarData(
  //                   spots: spots,
  //                   isCurved: true,
  //                   color: const Color(0xff3c76ad),
  //                   barWidth: 3,
  //                   dotData: const FlDotData(show: true),
  //                   belowBarData: BarAreaData(
  //                     show: true,
  //                     color: const Color(0xff3c76ad).withOpacity(0.2),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildOrderTrendsChart() {
    final recentOrders = _analyticsData['recentOrders'] as List? ?? [];
    final ordersByStatus = {
      'pending': 0,
      'processing': 0,
      'completed': 0,
      'cancelled': 0,
    };

    for (var order in recentOrders) {
      final status = order['status']?.toString().toLowerCase() ?? '';
      if (ordersByStatus.containsKey(status)) {
        ordersByStatus[status] = ordersByStatus[status]! + 1;
      }
    }

    return Container(
      height: 350,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Status Distribution',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    color: Colors.orange,
                    value: ordersByStatus['pending']!.toDouble(),
                    title: 'Pending\n${ordersByStatus['pending']}',
                    radius: 80,
                    titleStyle:
                        const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  PieChartSectionData(
                    color: Colors.blue,
                    value: ordersByStatus['processing']!.toDouble(),
                    title: 'Processing\n${ordersByStatus['processing']}',
                    radius: 80,
                    titleStyle:
                        const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  PieChartSectionData(
                    color: Colors.green,
                    value: ordersByStatus['completed']!.toDouble(),
                    title: 'Completed\n${ordersByStatus['completed']}',
                    radius: 80,
                    titleStyle:
                        const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  PieChartSectionData(
                    color: Colors.red,
                    value: ordersByStatus['cancelled']!.toDouble(),
                    title: 'Cancelled\n${ordersByStatus['cancelled']}',
                    radius: 80,
                    titleStyle:
                        const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularTimesChart() {
    return Container(
      height: 450,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Popular Order Times',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _buildHourlyOrdersChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyOrdersChart() {
    final recentOrders = _analyticsData['recentOrders'] as List? ?? [];
    final hourlyOrders = List.filled(24, 0);

    for (var order in recentOrders) {
      final date = DateTime.parse(order['date_created_gmt']);
      hourlyOrders[date.hour]++;
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: hourlyOrders.reduce((a, b) => a > b ? a : b) * 1.2,
        barGroups: hourlyOrders.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.toDouble(),
                color: const Color(0xff3c76ad),
                width: 8,
                borderRadius: BorderRadius.circular(2),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value % 4 != 0) return const Text('');
                return Text(
                  '${value.toInt()}:00',
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                );
              },
            ),
          ),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildCustomersTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCustomerMetrics(),
            const SizedBox(height: 20),
            _buildTopCustomers(),
            const SizedBox(height: 20),
            // _buildCustomerRetentionChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerMetrics() {
    final recentOrders = _analyticsData['recentOrders'] as List? ?? [];
    final uniqueCustomers =
        recentOrders.map((o) => o['customer_id']).toSet().length;
    final repeatCustomers = _calculateRepeatCustomers(recentOrders);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Customer Insights',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Active Customers',
                  uniqueCustomers.toString(),
                  Icons.people_outline,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Repeat Customers',
                  repeatCustomers.toString(),
                  Icons.repeat,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTopCustomers() {
    final topCustomers = _analyticsData['topCustomers'] as List? ?? [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Customers',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...topCustomers.map((customer) => _buildCustomerCard(customer)),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(Map<String, dynamic> customer) {
    final revenue = double.parse(customer['total_spent'].toString());
    final orders = int.parse(customer['order_count'].toString());

    return Card(
      color: Colors.white.withOpacity(0.05),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xff3c76ad),
          child: Text(
            customer['billing_email'][0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          customer['billing_email'],
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          'Orders: $orders | Revenue: \$${revenue.toStringAsFixed(2)}',
          style: const TextStyle(color: Colors.white70),
        ),
      ),
    );
  }

  Widget _buildCustomerRetentionChart() {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Customer Retention',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: _buildRetentionLineChart(),
          ),
        ],
      ),
    );
  }

  // Helper methods for calculations
  int _calculateRepeatCustomers(List<dynamic> orders) {
    final customerOrderCounts = {};
    for (var order in orders) {
      final customerId = order['customer_id'];
      customerOrderCounts[customerId] =
          (customerOrderCounts[customerId] ?? 0) + 1;
    }
    return customerOrderCounts.values.where((count) => count > 1).length;
  }

  List<Map<String, dynamic>> _calculateCustomerOrders(List<dynamic> orders) {
    final customerData = {};

    for (var order in orders) {
      final customerId = order['customer_id'];
      final email = order['billing_email'];
      final amount = double.parse(order['total_amount'].toString());

      if (!customerData.containsKey(customerId)) {
        customerData[customerId] = {
          'email': email,
          'orderCount': 0,
          'totalSpent': 0.0,
        };
      }

      customerData[customerId]['orderCount']++;
      customerData[customerId]['totalSpent'] += amount;
    }

    final sortedCustomers = customerData.values.toList()
      ..sort((a, b) => b['totalSpent'].compareTo(a['totalSpent']));

    return List<Map<String, dynamic>>.from(sortedCustomers);
  }

  Widget _buildRetentionLineChart() {
    final recentOrders = _analyticsData['recentOrders'] as List? ?? [];
    final retentionData = _calculateRetentionData(recentOrders);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 20,
          getDrawingHorizontalLine: (value) {
            return const FlLine(
              color: Colors.white10,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= retentionData.length) {
                  return const Text('');
                }
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Month ${value.toInt() + 1}',
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}%',
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                );
              },
            ),
          ),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: retentionData.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value);
            }).toList(),
            isCurved: true,
            color: const Color(0xff3c76ad),
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xff3c76ad).withOpacity(0.2),
            ),
          ),
        ],
        minY: 0,
        maxY: 100,
      ),
    );
  }

  List<double> _calculateRetentionData(List<dynamic> orders) {
    final monthlyCustomers = <int, Set<dynamic>>{};
    final retentionRates = <double>[];

    // Group customers by month
    for (var order in orders) {
      final date = DateTime.parse(order['date_created_gmt']);
      final monthKey = date.year * 12 + date.month;
      monthlyCustomers[monthKey] = (monthlyCustomers[monthKey] ?? {})
        ..add(order['customer_id']);
    }

    // Calculate retention rates
    final months = monthlyCustomers.keys.toList()..sort();
    if (months.isEmpty) return [0];

    final initialCustomers = monthlyCustomers[months.first]!;
    for (var i = 1; i < months.length; i++) {
      final currentCustomers = monthlyCustomers[months[i]]!;
      final retained = currentCustomers.intersection(initialCustomers).length;
      final rate = (retained / initialCustomers.length) * 100;
      retentionRates.add(rate);
    }

    return retentionRates.isEmpty ? [0] : retentionRates;
  }
}
