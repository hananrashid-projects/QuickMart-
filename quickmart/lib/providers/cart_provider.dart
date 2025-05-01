import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickmart/models/cart_item.dart';
import 'package:quickmart/models/product.dart';
import 'package:quickmart/providers/product_provider.dart';
import 'package:quickmart/repository/car_repository.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  final List<Product> _products;
  List<CartItem> _cart = [];
  final CartRepository _cartRepository;

  CartNotifier(this._cartRepository, this._products) : super([]);

  Future<void> initializeState() async {
    state = await _cartRepository.loadCarts();
  }

  // @override
  // List<Product> build() {
  //   initializeState();
  //   return [];
  // }

  // void initializeState() async {
  //   await loadCarts();
  // }

  // Future<void> loadCarts() async {
  //   var data = await rootBundle.loadString('assets/data/cart.json');
  //   var accountsMap = jsonDecode(data);
  //   _cart = [];
  //   for (var accountMap in accountsMap) {
  //     final product = Product.fromJson(accountMap);
  //     final cartItem = CartItem(
  //       productName: product.title,
  //       productId: product.id,
  //       quantity: 1,
  //       unitPrice: product.price,
  //     );
  //     _cart.add(cartItem);
  //     addToCart(product);
  //   }
  // }

  Future<void> addToCart(Product product) async {
    try {
      final index = state.indexWhere((item) => item.productId == product.id);
      if (index != -1) {
        state[index].quantity++;
        _cartRepository.addToCart(product);
      } else {
        final newCartItem = CartItem(
          productName: product.title,
          productId: product.id,
          quantity: 1,
          unitPrice: product.price,
        );
        _cartRepository.addToCart(product);
        state = [...state, newCartItem];
      }
    } catch (e) {
      print('Error adding to cart: $e');
    }
  }

  Future<void> updateQuantity(String productId, int newQuantity) async {
    final index = state.indexWhere((item) => item.productId == productId);
    if (index != -1 && newQuantity > 0) {
      await _cartRepository.updateQuantity(productId, newQuantity);
      state[index].quantity = newQuantity;
      state = [...state];
    }
  }

  Future<void> removeFromCart(CartItem product) async {
    try {
      await _cartRepository.removeCartItem(product.productId);
      state =
          state.where((item) => item.productId != product.productId).toList();
    } catch (e) {
      print('Error removing product from cart: $e');
    }
  }

  double get totalPrice => state
      .map((item) => item.unitPrice * item.quantity)
      .reduce((a, b) => a + b);

  String getImageName(String productId) {
    final product = _products.firstWhere(
      (product) => product.id == productId,
    );
    return product.imageName;
  }

  void decrementQuantity(Product product) {
    final index = state.indexWhere((item) => item.productId == product.id);
    if (index != -1) {
      if (state[index].quantity > 1) {
        state = [...state]..[index] = CartItem(
            productId: state[index].productId,
            productName: state[index].productName,
            quantity: state[index].quantity - 1,
            unitPrice: state[index].unitPrice,
          );
      } else {
        removeFromCart(state[index]);
      }
    }
  }

  void incrementQuantity(Product product) {
    final index = state.indexWhere((item) => item.productId == product.id);
    if (index != -1) {
      state = [...state]..[index] = CartItem(
          productId: state[index].productId,
          productName: state[index].productName,
          quantity: state[index].quantity + 1,
          unitPrice: state[index].unitPrice,
        );
    } else {
      addToCart(product);
    }
  }

  int getQuantity(Product product) {
    final cartItem = state.firstWhere(
      (item) => item.productId == product.id,
      orElse: () =>
          CartItem(productName: '', productId: '', quantity: 0, unitPrice: 0.0),
    );
    return cartItem.quantity;
  }
}

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  final productList = ref.watch(productNotifierProvider);
  return CartRepository([], productList);
});

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  final productList = ref.watch(productNotifierProvider);
  final cartRepository = ref.watch(cartRepositoryProvider);
  final cartNotifier = CartNotifier(cartRepository, productList);
  cartNotifier.initializeState();
  return cartNotifier;
});
