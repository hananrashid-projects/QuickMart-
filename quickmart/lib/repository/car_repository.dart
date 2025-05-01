import 'package:dio/dio.dart';
import 'package:quickmart/models/cart.dart';
import 'package:quickmart/models/cart_item.dart';
import 'package:quickmart/models/product.dart';

class CartRepository {
  final List<Product> _products;
  final _dio = Dio();
  final List<Cart> _carts;
  final String _baseUrl = 'https://quickmart.codedbyyou.com/api';
  CartRepository(this._carts, this._products);
  Future<List<CartItem>> loadCarts() async {
    try {
      final productsResponse = await _dio.get('$_baseUrl/products');
      if (productsResponse.statusCode == 200 && productsResponse.data != null) {
        _products.addAll(
          (productsResponse.data as List)
              .map((productJson) => Product.fromJson(productJson)),
        );
      } else {
        throw Exception('Failed to load products');
      }
      final cartsResponse = await _dio.get('$_baseUrl/cart');
      if (cartsResponse.statusCode == 200 && cartsResponse.data != null) {
        _carts.addAll(
          (cartsResponse.data as List)
              .map((cartJson) => Cart.fromJson(cartJson)),
        );
      } else {
        throw Exception('Failed to load carts');
      }

      final List<CartItem> cartItems = [];
      for (final cart in _carts) {
        final product = _products.firstWhere(
          (product) => product.id == cart.productId,
          orElse: () =>
              throw Exception('Product with ID ${cart.productId} not found'),
        );

        final cartItem = CartItem(
          productName: product.title,
          productId: product.id,
          quantity: cart.quantity,
          unitPrice: product.price,
        );
        cartItems.add(cartItem);
      }

      return cartItems;
    } catch (e) {
      print('Error loading carts: $e');
      rethrow;
    }
  }

  String getImageName(String productId) {
    try {
      final product = _products.firstWhere(
        (product) => product.id == productId,
        orElse: () => throw Exception('Product with ID $productId not found'),
      );
      return product.imageName;
    } catch (e) {
      print('Error finding product image: $e');
      rethrow;
    }
  }

  void addToCart(Product product) async {
    try {
      final index = _carts.indexWhere((item) => item.productId == product.id);
      if (index != -1) {
        _carts[index].quantity++;
        final cartItem = _carts[index];
        final cartItemJson = cartItem.toJson();
        await _dio.put('$_baseUrl/cart/${cartItem.productId}',
            data: cartItemJson);
      } else {
        final newCartItem = Cart(
          productId: product.id,
          quantity: 1,
        );

        final response =
            await _dio.post('$_baseUrl/cart', data: newCartItem.toJson());
        if (response.statusCode == 201) {
          _carts.add(Cart.fromJson(response.data));
        } else {
          throw Exception('Failed to add item to cart');
        }
      }
    } catch (e) {
      print('Error adding to cart: $e');
    }
  }

  Future<void> removeCartItem(String productId) async {
    try {
      final response = await _dio.delete('$_baseUrl/cart/$productId');
      if (response.statusCode == 204) {
        _carts.removeWhere((cart) => cart.productId == productId);
      } else {
        throw Exception('Failed to remove cart item');
      }
    } catch (e) {
      print('Error removing cart item: $e');
      rethrow;
    }
  }

  Future<void> updateQuantity(String productId, int newQuantity) async {
    try {
      final response = await _dio.put(
        '$_baseUrl/cart/$productId',
        data: {'quantity': newQuantity},
      );

      if (response.statusCode == 200) {
        final cart = _carts.firstWhere((cart) => cart.productId == productId);
        cart.quantity = newQuantity;
      } else {
        throw Exception('Failed to update cart item quantity');
      }
    } catch (e) {
      print('Error updating cart item quantity: $e');
    }
  }
  // Future<CartItem> addCart(CartItem cartitem) async {
  //   final url = '$_baseUrl/cart';
  //   Response response = await _dio.post(url, data: cartitem.toJson());
  //   if (response.statusCode != 201) {
  //     throw Exception('Failed to add transfer');
  //   }
  //   return cartitem;
  // }
}
