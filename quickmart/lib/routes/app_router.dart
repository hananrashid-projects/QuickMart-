import 'package:go_router/go_router.dart';
import 'package:quickmart/screens/cart_screen.dart';
import 'package:quickmart/screens/favorites_screen.dart';
import 'package:quickmart/screens/product_details_screen.dart';
import 'package:quickmart/screens/product_screen.dart';
import 'package:quickmart/screens/shell_screen.dart';

class AppRouter {
  static const home = (name: 'home', path: '/');
  static const cart = (name: 'cart', path: 'cart');
  static const favourite = (name: 'favourite', path: 'favourite');
  static const details = (
    name: 'productDetails',
    path: 'details/:id'
  ); // Update path to 'details/:id'

  static final router = GoRouter(
    initialLocation: home.path,
    routes: [
      ShellRoute(
        routes: [
          GoRoute(
            name: home.name,
            path: home.path,
            builder: (context, state) => const ProductScreen(),
            routes: [
              GoRoute(
                name: cart.name,
                path: cart.path,
                builder: (context, state) => CartScreen(),
              ),
              GoRoute(
                name: favourite.name,
                path: favourite.path,
                builder: (context, state) => FavoritesScreen(),
              ),
              GoRoute(
                name: details.name,
                path: details.path,
                builder: (context, state) {
                  final productId = state.pathParameters['id']!;
                  return ProductDetailsScreen(productId: productId);
                },
              ),
            ],
          ),
        ],
        builder: (context, state, child) => ShellScreen(child: child),
      ),
    ],
  );
}
