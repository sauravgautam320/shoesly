import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ReviewsPage extends StatefulWidget {
  final String productId;

  ReviewsPage({required this.productId});

  @override
  _ReviewsPageState createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  int? selectedRating;
  late Future<List<Map<String, dynamic>>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = fetchReviews();
  }

  Future<List<Map<String, dynamic>>> fetchReviews() async {
    try {
      print('Fetching reviews for product ID: ${widget.productId}');
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .get();

      if (docSnapshot.exists) {
        var product = docSnapshot.data() as Map<String, dynamic>;
        List<Map<String, dynamic>> reviews =
            List<Map<String, dynamic>>.from(product['reviews'] ?? []);
        print('Fetched ${reviews.length} reviews.');
        return reviews;
      } else {
        print('No product document found');
        return [];
      }
    } catch (e) {
      print('Error fetching reviews: $e');
      return [];
    }
  }

  void _filterReviews(int? rating) {
    setState(() {
      selectedRating = rating;
      _reviewsFuture = fetchReviews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('products')
              .doc(widget.productId)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading...');
            }

            if (snapshot.hasError) {
              print('Error fetching product data: ${snapshot.error}');
              return const Text('Error');
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              print('No product data found');
              return const Text('No product data');
            }

            var product = snapshot.data!.data() as Map<String, dynamic>;
            return Row(
              children: [
                Text('Review (${product['total_reviews'] ?? 0})'),
                const Spacer(),
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 4),
                Text('${product['rating']?.toStringAsFixed(1) ?? '0.0'}',
                    style: const TextStyle(fontSize: 18)),
              ],
            );
          },
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterButton('All', null),
                _buildFilterButton('5 Stars', 5),
                _buildFilterButton('4 Stars', 4),
                _buildFilterButton('3 Stars', 3),
                _buildFilterButton('2 Stars', 2),
                _buildFilterButton('1 Star', 1),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _reviewsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  print('Error fetching reviews: ${snapshot.error}');
                  return const Center(child: Text('Error loading reviews'));
                }

                final reviews = snapshot.data ?? [];
                print('Reviews length: ${reviews.length}');
                if (reviews.isEmpty) {
                  print('No reviews found');
                  return const Center(child: Text('No reviews found'));
                }

                final filteredReviews = selectedRating == null
                    ? reviews
                    : reviews
                        .where((review) =>
                            review['rating']?.toInt() == selectedRating)
                        .toList();

                if (filteredReviews.isEmpty) {
                  return Center(
                    child: Text('No reviews with ${selectedRating ?? 0} stars'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: filteredReviews.length,
                  itemBuilder: (context, index) {
                    var review = filteredReviews[index];
                    print('Review: $review'); // Debug print to trace data
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(review['user_image'] ??
                            'https://via.placeholder.com/150'),
                      ),
                      title: Text(review['user_name'] ?? 'Anonymous'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              RatingBarIndicator(
                                rating: review['rating'] != null
                                    ? review['rating'].toDouble()
                                    : 0.0,
                                itemBuilder: (context, index) => const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                itemCount: 5,
                                itemSize: 20.0,
                              ),
                              const SizedBox(width: 8),
                              const Text('Today',
                                  style: TextStyle(fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            review['comment'] ?? '',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, int? rating) {
    bool isSelected = selectedRating == rating;
    return TextButton(
      onPressed: () => _filterReviews(rating),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.black : Colors.grey,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
