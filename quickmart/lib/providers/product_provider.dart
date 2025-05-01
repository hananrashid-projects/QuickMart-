import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickmart/models/product.dart';
import 'package:quickmart/repository/product_repository.dart';

class ProductNotifier extends Notifier<List<Product>> {
  List<Product> _allProducts = [];
  List<String> _categories = [];
  String _selectedCategory = 'All';
  final ProductRepository _productRepository = ProductRepository();

  @override
  List<Product> build() {
    initializeState();
    return [];
  }

  void initializeState() async {
    await loadCategories();
    await loadProducts();
  }

  Future<void> loadCategories() async {
    _categories = await _productRepository.loadCategories();
    _categories.insert(0, 'All');
  }

  Future<void> loadProducts() async {
    try {
      List<Product> products = await _productRepository.loadProducts();
      _allProducts = products;
      state = [..._allProducts];
    } catch (e) {
      print('Error loading products: $e');
    }
  }

  List<String> get categories => _categories;

  void selectCategory(String category) {
    _selectedCategory = category;
    filterByCategory(_selectedCategory);
  }

  void filterByCategory(String category) {
    if (category == 'All') {
      state = List.from(_allProducts);
      return;
    }
    state = _allProducts
        .where((product) =>
            product.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  Future<void> filterByNameAndCategory(String name, String category) async {
    List<Product> products =
        await _productRepository.filterByNameAndCategory(name, category);
    if (name.isNotEmpty) {
      products = products
          .where((product) =>
              product.title.toLowerCase().contains(name.toLowerCase()))
          .toList();
    }
    if (category != "All") {
      products = products
          .where((product) =>
              product.category.toLowerCase() == category.toLowerCase())
          .toList();
    }

    state = products;
  }

  void filterByID(String id) {
    state = _allProducts.where((product) => product.id == id).toList();
  }

  // Future<Product> getProductById(String id) async {
  //   return await _productRepository.getProductById(id);
  // }
  Product getProductById(String productId) {
    return _allProducts.firstWhere((product) => product.id == productId);
  }
}

final productNotifierProvider =
    NotifierProvider<ProductNotifier, List<Product>>(() => ProductNotifier());
