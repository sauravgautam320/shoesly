import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shoesly/Screens/cart_page.dart';
import 'package:shoesly/Screens/reviews_page.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;

  ProductDetailPage({required this.productId});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  String selectedSize = '';
  String selectedColor = '0xFF000000'; // Default to the first color

  final Map<String, String> colorMap = {
    '0xFF000000': 'Black',
    '0xFFFFFFFF': 'White',
    '0xFFFF0000': 'Red',
    '0xFF00FF00': 'Green',
    '0xFF0000FF': 'Blue',
    '0xFFFFFF00': 'Yellow',
    '0xFF00FFFF': 'Cyan',
    '0xFFFF00FF': 'Magenta',
    '0xFFC0C0C0': 'Silver',
    '0xFF808080': 'Gray',
    '0xFF800000': 'Maroon',
    '0xFF808000': 'Olive',
    '0xFF800080': 'Purple',
    '0xFF008080': 'Teal',
    '0xFF000080': 'Navy',
    '0xFFFFA500': 'Orange',
  };

  @override
  void initState() {
    super.initState();
  }

  Future<void> addToCart(
    String productId,
    int quantity,
    double totalPrice,
    String productImage,
    String productSize,
    String productBrand,
    String productName,
    String productColor,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('cart').add({
        'productId': productId,
        'quantity': quantity,
        'totalPrice': totalPrice,
        'productImage': productImage,
        'productSize': productSize,
        'productBrand': productBrand,
        'productName': productName,
        'productColor': productColor,
        'addedAt': Timestamp.now(),
      });
      return Future.value(); // Indicate success
    } catch (e) {
      // Handle the error
      print('Error adding to cart: $e');
      return Future.error('Error adding to cart');
    }
  }

  void _showAddToCartBottomSheet(
    BuildContext context,
    double price,
    String productImage,
    String productSize,
    String productBrand,
    String productName,
    String productColor,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      barrierColor: Colors.black.withOpacity(0.5),
      isDismissible: false,
      enableDrag: false,
      builder: (BuildContext context) {
        int quantity = 1;
        bool isLoading = false;
        bool isConfirmationScreen = false;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            void showConfirmationScreen() {
              setState(() {
                isConfirmationScreen = true;
              });
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: isConfirmationScreen
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          'assets/svg/tick-circle.svg', // Path to your SVG asset
                          width: 100, // Set the width
                          height: 100, // Set the height
                        ),
                        const SizedBox(height: 20),
                        const Text('Added to cart',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text('$quantity Item${quantity > 1 ? 's' : ''} Total',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.grey)),
                        const SizedBox(height: 30),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'BACK EXPLORE',
                                  style: TextStyle(color: Colors.black),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  side: const BorderSide(color: Colors.black),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CartPage(),
                                    ),
                                  );
                                },
                                child: const Text('TO CART'),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.black,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Add to cart',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        const Divider(),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Quantity',
                                style: TextStyle(fontSize: 16)),
                            Row(
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.black),
                                  ),
                                  child: Center(
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.remove, size: 16),
                                      onPressed: () {
                                        setState(() {
                                          if (quantity > 1) quantity--;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text('$quantity',
                                    style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: 16),
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.black),
                                  ),
                                  child: Center(
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.add, size: 16),
                                      onPressed: () {
                                        setState(() {
                                          quantity++;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Divider(),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Total Price',
                                    style: TextStyle(fontSize: 16)),
                                Text(
                                    '\$${(price * quantity).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                            SizedBox(
                              width: 150,
                              child: ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () async {
                                        setState(() {
                                          isLoading = true;
                                        });
                                        await addToCart(
                                            widget.productId,
                                            quantity,
                                            price * quantity,
                                            productImage,
                                            productSize,
                                            productBrand,
                                            productName,
                                            productColor);
                                        setState(() {
                                          isLoading = false;
                                        });
                                        showConfirmationScreen();
                                      },
                                child: isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white)
                                    : const Text('ADD TO CART'),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.black,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        centerTitle: true,
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
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('products')
            .doc(widget.productId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Product not found'));
          }

          var product = snapshot.data!.data() as Map<String, dynamic>;

          // Handle potential null values
          List<String> images = product['image'] != null
              ? List<String>.from(product['image'])
              : ['https://via.placeholder.com/150'];

          String name = product['name'] ?? 'Unknown';
          double price =
              product['price'] != null ? product['price'].toDouble() : 0.0;
          String description =
              product['description'] ?? 'No description available';
          String brand = product['brand'] ?? 'No brand available';
          double rating =
              product['rating'] != null ? product['rating'].toDouble() : 0.0;
          List<String> sizes = product['sizes'] != null
              ? List<String>.from(product['sizes'])
              : [];
          List<String> colors = product['colors'] != null
              ? List<String>.from(product['colors'])
              : [];
          List<Map<String, dynamic>> reviews = product['reviews'] != null
              ? List<Map<String, dynamic>>.from(product['reviews'])
              : [];
          int totalReviews = product['total_reviews'] ?? 0;

          // Set default selected size
          if (selectedSize.isEmpty && sizes.isNotEmpty) {
            selectedSize = sizes[0];
          }

          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  SizedBox(
                    height: 300,
                    child: PageView.builder(
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return CachedNetworkImage(
                          imageUrl: images[index],
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: colors.map((color) {
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedColor = color;
                                });
                              },
                              child: CircleAvatar(
                                radius: 10,
                                backgroundColor: Color(int.parse(color)),
                                child: selectedColor == color
                                    ? Icon(Icons.check,
                                        color: Colors.white, size: 16)
                                    : null,
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(name,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: rating,
                        itemBuilder: (context, index) =>
                            const Icon(Icons.star, color: Colors.amber),
                        itemCount: 5,
                        itemSize: 20.0,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        rating.toStringAsFixed(1),
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '($totalReviews Reviews)',
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Size',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return Wrap(
                        spacing: 8.0,
                        children: sizes.map((size) {
                          bool isSelected = size == selectedSize;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedSize = size;
                              });
                            },
                            child: Chip(
                              label: Text(size),
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                              backgroundColor:
                                  isSelected ? Colors.black : Colors.grey[200],
                              shape: CircleBorder(
                                side: BorderSide(
                                  color:
                                      isSelected ? Colors.black : Colors.grey,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Description',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(description, style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 16),
                  Text('Review ($totalReviews)',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...reviews
                      .take(3)
                      .map((review) => ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                  review['user_image'] ??
                                      'https://via.placeholder.com/150'),
                            ),
                            title: Text(review['user_name'] ?? 'Anonymous'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RatingBarIndicator(
                                  rating: review['rating'] != null
                                      ? review['rating'].toDouble()
                                      : 0.0,
                                  itemBuilder: (context, index) => const Icon(
                                      Icons.star,
                                      color: Colors.amber),
                                  itemCount: 5,
                                  itemSize: 20.0,
                                ),
                                const SizedBox(height: 4),
                                Text(review['comment'] ?? '',
                                    style: const TextStyle(fontSize: 14)),
                              ],
                            ),
                          ))
                      .toList(),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReviewsPage(
                            productId: widget.productId,
                          ),
                        ),
                      );
                    },
                    child: const Text('SEE ALL REVIEW'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                  const SizedBox(
                      height:
                          100), // To make sure there's enough space for the fixed bottom container
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text('Price',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              )),
                          Text('\$${price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(
                        width: 200,
                        child: ElevatedButton(
                          onPressed: () {
                            if (selectedColor.isEmpty || selectedSize.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please select color and size'),
                                ),
                              );
                              return;
                            }
                            _showAddToCartBottomSheet(
                              context,
                              price,
                              images[0],
                              selectedSize,
                              brand,
                              name,
                              colorMap[selectedColor]!,
                            );
                          },
                          child: const Text('ADD TO CART'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
