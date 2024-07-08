import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shoesly/Screens/cart_page.dart';
import '../Widgets/filter_bottom_sheet.dart';
import 'product_detail_page.dart';

class DiscoverPage extends StatefulWidget {
  @override
  _DiscoverPageState createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final ScrollController _scrollController = ScrollController();
  List<DocumentSnapshot> _products = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _documentLimit = 100;
  DocumentSnapshot? _lastDocument;
  String _selectedFilter = 'All';
  bool _isFilterApplied = false;

  List<String> _selectedBrands = [];
  double _minPrice = 0;
  double _maxPrice = 1750;
  String? _sortBy;
  String? _selectedGender;
  List<String> _selectedColors = [];

  @override
  void initState() {
    super.initState();
    _getProducts();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _hasMore) {
        _getProducts();
      }
    });
  }

  Future<void> _getProducts() async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });

      Query query = FirebaseFirestore.instance
          .collection('products')
          .limit(_documentLimit);

      if (_selectedFilter != 'All') {
        query = query.where('brand', isEqualTo: _selectedFilter);
      }
      if (_selectedBrands.isNotEmpty) {
        query = query.where('brand', whereIn: _selectedBrands);
      }
      if (_selectedGender != null) {
        query = query.where('gender', isEqualTo: _selectedGender);
      }
      if (_selectedColors.isNotEmpty) {
        query = query.where('colors', arrayContainsAny: _selectedColors);
      }
      query = query.where('price', isGreaterThanOrEqualTo: _minPrice);
      query = query.where('price', isLessThanOrEqualTo: _maxPrice);

      if (_sortBy != null) {
        if (_sortBy == 'Most recent') {
          query = query.orderBy('addedAt', descending: true);
        } else if (_sortBy == 'Lowest price') {
          query = query.orderBy('price', descending: false);
        } else if (_sortBy == 'Highest reviews') {
          query = query.orderBy('rating', descending: true);
        }
      }

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      try {
        QuerySnapshot querySnapshot = await query.get();
        if (querySnapshot.docs.length < _documentLimit) {
          _hasMore = false;
        }
        if (querySnapshot.docs.isNotEmpty) {
          _lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
          _products.addAll(querySnapshot.docs);
        }
      } catch (e) {
        print("Error fetching products: $e");
        if (e is FirebaseException && e.code == 'failed-precondition') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                "The query requires an index. Check the console for details."),
          ));
        }
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _changeFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      _products.clear();
      _lastDocument = null;
      _hasMore = true;
    });
    _getProducts();
  }

  void _applyFilter({
    List<String>? brands,
    double minPrice = 0,
    double maxPrice = 1750,
    String? sortBy,
    String? gender,
    List<String>? colors,
  }) {
    setState(() {
      _selectedBrands = brands ?? [];
      _minPrice = minPrice;
      _maxPrice = maxPrice;
      _sortBy = sortBy;
      _selectedGender = gender;
      _selectedColors = colors ?? [];
      _products.clear();
      _lastDocument = null;
      _hasMore = true;
      _isFilterApplied = brands!.isNotEmpty ||
          minPrice > 0 ||
          maxPrice < 1750 ||
          sortBy != null ||
          gender != null ||
          colors!.isNotEmpty;
    });
    _getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        actions: <Widget>[
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('cart').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return IconButton(
                  icon: SvgPicture.asset(
                    'assets/svg/cart-empty.svg',
                    width: 24,
                    height: 24,
                  ),
                  tooltip: 'Open shopping cart',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CartPage(),
                      ),
                    );
                  },
                );
              }

              final cartItems = snapshot.data!.docs;
              final cartIcon = cartItems.isEmpty
                  ? 'assets/svg/cart-empty.svg'
                  : 'assets/svg/cart.svg';

              return IconButton(
                icon: SvgPicture.asset(
                  cartIcon,
                  width: 24,
                  height: 24,
                ),
                tooltip: 'Open shopping cart',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CartPage(),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterButton('All'),
                _buildFilterButton('Nike'),
                _buildFilterButton('Jordan'),
                _buildFilterButton('Adidas'),
                _buildFilterButton('Reebok'),
                _buildFilterButton('Vans'),
                _buildFilterButton('Puma'),
              ],
            ),
          ),
          Expanded(
            child: _isLoading && _products.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    controller: _scrollController,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    padding: const EdgeInsets.all(10),
                    itemCount: _products.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _products.length) {
                        return _hasMore
                            ? const Center(child: CircularProgressIndicator())
                            : const SizedBox();
                      }
                      var product =
                          _products[index].data() as Map<String, dynamic>;
                      var images = List<String>.from(product['image'] ?? []);
                      var imageUrl = images.isNotEmpty
                          ? images[0]
                          : 'https://via.placeholder.com/300';
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailPage(
                                  productId: _products[index].id),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product['name'] ?? '',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        RatingBarIndicator(
                                          rating: (product['rating'] ?? 0)
                                              .toDouble(),
                                          itemBuilder: (context, index) =>
                                              const Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                          ),
                                          itemCount: 5,
                                          itemSize: 14.0,
                                          direction: Axis.horizontal,
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            '(${product['total_reviews'] ?? 0} Reviews)',
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '\$${(product['price'] ?? 0).toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => FilterBottomSheet(
              selectedBrands: _selectedBrands,
              minPrice: _minPrice,
              maxPrice: _maxPrice,
              sortBy: _sortBy,
              selectedGender: _selectedGender,
              selectedColors: _selectedColors,
            ),
          );
          if (result != null) {
            _applyFilter(
              brands: result['brands'],
              minPrice: result['minPrice'],
              maxPrice: result['maxPrice'],
              sortBy: result['sortBy'],
              gender: result['gender'],
              colors: result['colors'],
            );
          }
        },
        icon: SvgPicture.asset(
          _isFilterApplied
              ? 'assets/svg/filter.svg'
              : 'assets/svg/filter-empty.svg', // Path to your SVG asset
          color: _isFilterApplied ? null : Colors.white,
          width: 24, // Set the width
          height: 24, // Set the height
        ),
        label: const Text('FILTER'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildFilterButton(String filter) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextButton(
        onPressed: () => _changeFilter(filter),
        child: Text(filter),
        style: ElevatedButton.styleFrom(
          foregroundColor:
              _selectedFilter == filter ? Colors.black : Colors.grey,
        ),
      ),
    );
  }

}
