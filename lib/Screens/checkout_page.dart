import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CheckoutPage extends StatefulWidget {
  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final CollectionReference cart =
      FirebaseFirestore.instance.collection('cart');
  final CollectionReference orders =
      FirebaseFirestore.instance.collection('orders');

  void _showPaymentSuccessPopup(BuildContext context) async {
    await _createOrder(); // Create an order in Firestore
    _clearCart(); // Clear the cart
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/svg/tick-circle.svg', // Path to your SVG asset
                width: 100, // Set the width
                height: 100, // Set the height
              ),
              const SizedBox(height: 20),
              const Text('Payment Successful',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text('EXPLORE MORE'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _clearCart() async {
    var snapshot = await cart.get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> _createOrder() async {
    var snapshot = await cart.get();
    List<Map<String, dynamic>> orderItems = snapshot.docs.map((doc) {
      return {
        'productId': doc['productId'],
        'quantity': doc['quantity'],
        'totalPrice': doc['totalPrice'],
        'productImage': doc['productImage'],
        'productSize': doc['productSize'],
        'productBrand': doc['productBrand'],
        'productName': doc['productName'],
        'productColor': doc['productColor'],
      };
    }).toList();

    double subTotal =
        orderItems.fold(0.0, (sum, item) => sum + item['totalPrice']);
    double shipping = 20.0; // Example shipping cost
    double totalOrder = subTotal + shipping;

    await orders.add({
      'orderItems': orderItems,
      'subTotal': subTotal,
      'shipping': shipping,
      'totalOrder': totalOrder,
      'orderDate': Timestamp.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Summary'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: cart.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final cartItems = snapshot.data!.docs;
          double subTotal = 0.0;
          double shipping = 20.0; // Example shipping cost

          cartItems.forEach((item) {
            subTotal += item['totalPrice'];
          });

          double totalOrder = subTotal + shipping;

          return Stack(
            children: [
              ListView(
                padding:
                    const EdgeInsets.only(bottom: 100, left: 16, right: 16),
                children: [
                  const ListTile(
                    title: Text('Information',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  ListTile(
                    title: const Text('Payment Method'),
                    subtitle: const Text('Credit Card'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Navigate to payment method selection
                    },
                  ),
                  ListTile(
                    title: const Text('Location'),
                    subtitle: const Text('Semarang, Indonesia'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Navigate to location selection
                    },
                  ),
                  const ListTile(
                    title: Text('Order Detail',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  ...cartItems.map((item) {
                    return ListTile(
                      title: Text(item['productName']),
                      subtitle: Text(
                        '${item['productBrand']} . ${item['productColor']} . Qty ${item['quantity']}',
                      ),
                      trailing: Text(
                        '\$${(item['totalPrice']).toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  }).toList(),
                  const ListTile(
                    title: Text('Payment Detail',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  ListTile(
                    title: const Text('Sub Total'),
                    trailing: Text('\$${subTotal.toStringAsFixed(2)}'),
                  ),
                  ListTile(
                    title: const Text('Shipping'),
                    trailing: Text('\$${shipping.toStringAsFixed(2)}'),
                  ),
                  ListTile(
                    title: const Text('Total Order'),
                    trailing: Text(
                      '\$${totalOrder.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Grand Total',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey)),
                          Text('\$${totalOrder.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(
                        width: 150,
                        child: ElevatedButton(
                          onPressed: () {
                            // Process payment
                            _showPaymentSuccessPopup(context);
                          },
                          child: const Text('PAYMENT'),
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
