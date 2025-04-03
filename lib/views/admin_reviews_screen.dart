import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rfkicks_admin/services/admin_api_service.dart';

class AdminReviewsScreen extends StatefulWidget {
  final int serviceId;

  const AdminReviewsScreen({super.key, required this.serviceId});

  @override
  State<AdminReviewsScreen> createState() => _AdminReviewsScreenState();
}

class _AdminReviewsScreenState extends State<AdminReviewsScreen> {
  int? selectedRating;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Service Reviews'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          FutureBuilder<List<Map<String, dynamic>>>(
            future: AdminApiService.getServiceReviews(widget.serviceId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: Colors.white));
              }

              if (snapshot.hasError) {
                return const Center(
                    child: Text('Failed to load reviews',
                        style: TextStyle(color: Colors.white)));
              }

              final allReviews = snapshot.data ?? [];
              final reviews = selectedRating == null
                  ? allReviews
                  : allReviews
                      .where((review) => review['rating'] == selectedRating)
                      .toList();

              final averageRating = reviews.isEmpty
                  ? 0.0
                  : reviews.fold<double>(
                          0, (sum, review) => sum + review['rating']) /
                      reviews.length;

              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Customer Reviews",
                      style: TextStyle(
                          fontSize: 28,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          "${reviews.length} Reviews",
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          "${averageRating.toStringAsFixed(1)} ★",
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(null, 'All Reviews'),
                          ...List.generate(
                              5,
                              (index) => _buildFilterChip(
                                  5 - index, '${5 - index} ★')),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: reviews.isEmpty
                          ? Center(
                              child: Text(
                                selectedRating == null
                                    ? 'No reviews yet'
                                    : 'No $selectedRating-star reviews',
                                style: const TextStyle(color: Colors.white),
                              ),
                            )
                          : ListView.builder(
                              itemCount: reviews.length,
                              itemBuilder: (context, index) =>
                                  _buildReviewItem(reviews[index]),
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(int? rating, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selectedRating == rating,
        onSelected: (_) => setState(() => selectedRating = rating),
        backgroundColor: Colors.white.withOpacity(0.1),
        selectedColor: const Color(0xff3c76ad),
        labelStyle: TextStyle(
            color: selectedRating == rating ? Colors.white : Colors.black,
            fontSize: 12),
        checkmarkColor: Colors.white,
      ),
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> review) {
    final date =
        DateFormat('MMM dd, yyyy').format(DateTime.parse(review['created_at']));

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                review['user_name'],
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                date,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                "★" * review['rating'],
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xff3c76ad),
                ),
              ),
              Text(
                " (${review['rating']}.0)",
                style: const TextStyle(
                  color: Color(0xff3c76ad),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review['review_text'],
            style: const TextStyle(fontSize: 15, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
