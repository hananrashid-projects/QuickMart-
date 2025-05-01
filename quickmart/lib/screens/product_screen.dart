import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quickmart/providers/cart_provider.dart';
import 'package:quickmart/providers/product_provider.dart';
import 'package:quickmart/routes/app_router.dart';

class ProductScreen extends ConsumerStatefulWidget {
  const ProductScreen({super.key});

  @override
  ConsumerState<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends ConsumerState<ProductScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      // Use a fallback category if _selectedCategory is null
      ref.read(productNotifierProvider.notifier).filterByNameAndCategory(
          _searchController.text, _selectedCategory ?? 'All');
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadCategories();
    });
  }

  Future<void> loadCategories() async {
    final categories = ref.read(productNotifierProvider.notifier).categories;
    if (categories.isNotEmpty) {
      setState(() {
        _selectedCategory = categories[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.search),
              contentPadding: const EdgeInsets.all(15),
              filled: true,
              fillColor: Colors.grey[300],
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: DropdownButton<String>(
              value: _selectedCategory,
              icon: const Icon(Icons.menu, color: Colors.green),
              dropdownColor: Colors.white,
              underline: Container(
                height: 2,
                color: Colors.green,
              ),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue;
                });
                ref
                    .read(productNotifierProvider.notifier)
                    .selectCategory(newValue!);
              },
              items: ref
                  .watch(productNotifierProvider.notifier)
                  .categories
                  .map<DropdownMenuItem<String>>((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 0.9,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return GestureDetector(
            onTap: () {
              context.pushNamed(AppRouter.details.name,
                  pathParameters: {'id': product.id});
            },
            child: Card(
              elevation: 2,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(
                  color: Color.fromARGB(255, 192, 190, 190),
                  width: 3,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
                    Container(
                      height: 120,
                      width: 200,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image:
                              AssetImage('assets/images/${product.imageName}'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      product.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      product.category.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'QR ${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            ref.read(cartProvider.notifier).addToCart(product);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: SizedBox(
                            width: 40,
                            height: 40,
                            child: const Icon(Icons.add, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
