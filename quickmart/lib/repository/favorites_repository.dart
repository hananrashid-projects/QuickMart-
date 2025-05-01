import 'package:dio/dio.dart';
import 'package:quickmart/models/favourite.dart';
import 'package:quickmart/models/product.dart';

class FavoritesRepository {
  final List<Product> _products = [];
  final List<Favorite> _favs = [];
  final Dio _dio = Dio();
  final String _baseUrl = 'https://quickmart.codedbyyou.com/api';
  Future<List<Product>> loadFavorites() async {
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

      final favsResponse = await _dio.get('$_baseUrl/favorites');
      if (favsResponse.statusCode == 200 && favsResponse.data != null) {
        _favs.addAll(
          (favsResponse.data as List).map((f) => Favorite.fromJson(f)),
        );
      } else {
        throw Exception('Failed to load favorites');
      }

      final List<Product> favoriteProducts = [];
      for (final fav in _favs) {
        final product = _products.firstWhere((prod) => prod.id == fav.productId,
            orElse: () => Product(
                id: '',
                title: '',
                category: '',
                description: '',
                price: 0,
                rating: 0,
                imageName: ''));
        if (product.id.isNotEmpty) {
          favoriteProducts.add(product);
        }
      }

      return favoriteProducts;
    } catch (e) {
      print('Error loading favorites: $e');
      rethrow;
    }
  }

  Future<void> addFavorite(Product product) async {
    try {
      final newFavorite = Favorite(productId: product.id);
      final response =
          await _dio.post('$_baseUrl/favorites', data: newFavorite.toJson());
      if (response.statusCode == 201) {
        _favs.add(newFavorite);
      } else {
        throw Exception(
            'Failed to add favorite, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding favorite: $e');
      rethrow;
    }
  }

  Future<void> removeFavorite(Product product) async {
    try {
      final favToRemove =
          _favs.firstWhere((fav) => fav.productId == product.id);
      final response =
          await _dio.delete('$_baseUrl/favorites/${favToRemove.productId}');
      if (response.statusCode == 204) {
        _favs.remove(favToRemove);
      } else {
        throw Exception(
            'Failed to remove favorite, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error removing favorite: $e');
      rethrow;
    }
  }
}
