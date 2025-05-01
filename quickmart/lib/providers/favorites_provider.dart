import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickmart/models/product.dart';
import 'package:quickmart/repository/favorites_repository.dart';

class FavoritesNotifier extends StateNotifier<List<Product>> {
  final FavoritesRepository _repository;

  FavoritesNotifier(this._repository) : super([]) {
    loadFavorites();
  }
  Future<void> loadFavorites() async {
    final favoriteProducts = await _repository.loadFavorites();
    state = favoriteProducts;
  }

  Future<void> toggleFavorite(Product product) async {
    if (isFavorite(product)) {
      await _repository.removeFavorite(product);
      state = state.where((p) => p.id != product.id).toList();
    } else {
      await _repository.addFavorite(product);
      state = [...state, product];
    }
  }

  bool isFavorite(Product product) {
    return state.any((p) => p.id == product.id);
  }

  List<Product> get favorites => state;
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, List<Product>>((ref) {
  final favoritesRepository = ref.watch(favoritesRepositoryProvider);
  return FavoritesNotifier(favoritesRepository);
});
final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepository();
});
