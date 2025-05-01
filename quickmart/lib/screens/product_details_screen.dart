import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quickmart/providers/cart_provider.dart';
import 'package:quickmart/providers/product_provider.dart';
import 'package:quickmart/providers/favorites_provider.dart';
import 'package:quickmart/routes/app_router.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  int _temporaryQuantity = 0;
  bool isDetailsExpanded = false;

  @override
  Widget build(BuildContext context) {
    final product = ref
        .watch(productNotifierProvider.notifier)
        .getProductById(widget.productId);
    final isFavorite = ref.watch(favoritesProvider).contains(product);

    // Price based on temporary quantity
    final totalPrice = product.price * _temporaryQuantity;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  color: Colors.grey[300],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  child: Container(
                    color: Colors.white,
                    child: Center(
                      child: Image.asset(
                        'assets/images/${product.imageName}',
                        width: 300,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Product Title and Heart Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                product.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isFavorite
                                    ? const Color.fromARGB(255, 186, 30, 30)
                                    : Colors.grey,
                              ),
                              onPressed: () {
                                ref
                                    .read(favoritesProvider.notifier)
                                    .toggleFavorite(product);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '1kg, Price',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Quantity Selector and Price on the same level
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove, color: Colors.black),
                        onPressed: () {
                          if (_temporaryQuantity > 0) {
                            setState(() {
                              _temporaryQuantity--;
                              // Update temporary quantity in CartNotifier
                            });
                          }
                        },
                        iconSize: 24,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _temporaryQuantity.toString(),
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add, color: Colors.black),
                        onPressed: () {
                          setState(() {
                            _temporaryQuantity++;
                            // Update temporary quantity in CartNotifier
                          });
                        },
                        iconSize: 24,
                      ),
                    ],
                  ),
                  // Price Display
                  Text(
                    '\$${totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.grey),
              const SizedBox(height: 4),
              // Product Detail Section
              GestureDetector(
                onTap: () {
                  setState(() {
                    isDetailsExpanded = !isDetailsExpanded;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Product Detail',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      isDetailsExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.black,
                      size: 20,
                    ),
                  ],
                ),
              ),
              if (isDetailsExpanded)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    product.description,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              const Divider(color: Colors.grey),
              const SizedBox(height: 4),
              // Nutrition Section
              Text(
                'Nutritions',
                style: const TextStyle(fontSize: 16),
              ),
              const Divider(color: Colors.grey),
              const SizedBox(height: 8),
              // Review Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Review',
                    style: TextStyle(fontSize: 16),
                  ),
                  Row(
                    children: List.generate(5, (index) {
                      return index < product.rating
                          ? const Icon(Icons.star,
                              color: Colors.yellow, size: 16)
                          : const Icon(Icons.star_border,
                              color: Colors.yellow, size: 16);
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Add to Basket Button
              ElevatedButton(
                onPressed: () {
                  // Add the specified quantity of the product to the cart
                  for (int i = 0; i < _temporaryQuantity; i++) {
                    ref.read(cartProvider.notifier).addToCart(product);
                  }

                  // Reset the temporary quantity and navigate to home
                  setState(() {
                    _temporaryQuantity = 0;
                  });

                  context.go(AppRouter.home.path);
                },
                child: const Text(
                  'Add to Basket',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: const Color.fromARGB(255, 68, 192, 136),
                  minimumSize: Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
