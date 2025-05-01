import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quickmart/providers/favorites_provider.dart';
import 'package:quickmart/providers/cart_provider.dart';
import 'package:quickmart/routes/app_router.dart';

class FavoritesScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: Column(
        children: [
          Expanded(
            child: favorites.isEmpty
                ? Center(child: Text('No favorites added yet.'))
                : ListView.builder(
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      final product = favorites[index];
                      return ListTile(
                        leading:
                            Image.asset('assets/images/${product.imageName}'),
                        title: Text(product.title),
                        subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.favorite, color: Colors.red),
                          onPressed: () {
                            ref
                                .read(favoritesProvider.notifier)
                                .toggleFavorite(product);
                          },
                        ),
                        onTap: () {
                          context.pushNamed(AppRouter.details.name,
                              pathParameters: {'id': product.id});
                        },
                      );
                    },
                  ),
          ),
          if (favorites.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  for (var product in favorites) {
                    ref.read(cartProvider.notifier).addToCart(product);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('All items added to the cart!')),
                  );
                },
                child: const Text('Add All to Cart'),
              ),
            ),
        ],
      ),
    );
  }
}
