import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickmart/providers/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    if (cartItems.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Center(child: Text('My Cart')),
        ),
        body: Center(
          child: Text('Your cart is empty', style: TextStyle(fontSize: 18)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('My Cart'),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final cartItem = cartItems[index];
                final imageName = cartNotifier.getImageName(cartItem.productId);

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: AssetImage('assets/images/$imageName'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(cartItem.productName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  )),
                              SizedBox(height: 4),
                              Text('\$${cartItem.unitPrice} / unit',
                                  style: TextStyle(color: Colors.grey)),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (cartItem.quantity > 1) {
                                        cartNotifier.updateQuantity(
                                            cartItem.productId,
                                            cartItem.quantity - 1);
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            255, 255, 255, 255),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(Icons.remove),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text('${cartItem.quantity}',
                                      style: TextStyle(fontSize: 16)),
                                  SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: () {
                                      cartNotifier.updateQuantity(
                                          cartItem.productId,
                                          cartItem.quantity + 1);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            255, 255, 255, 255),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(Icons.add),
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    '\$${(cartItem.quantity * cartItem.unitPrice).toStringAsFixed(2)}',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.cancel,
                              color: const Color.fromARGB(255, 182, 182, 182)),
                          onPressed: () {
                            cartNotifier.removeFromCart(cartItem);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: ElevatedButton(
              onPressed: () {},
              child: Text(
                'Go to Checkout: \$${cartNotifier.totalPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 78, 202, 149),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 80),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
