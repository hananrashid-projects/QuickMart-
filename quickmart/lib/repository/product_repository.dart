import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:quickmart/models/product.dart';

class ProductRepository {
  final _dio = Dio();

  final String _baseUrl = 'https://quickmart.codedbyyou.com/api';
  Future<List<String>> loadCategories() async {
    try {
      Response response = await _dio.get('$_baseUrl/categories');
      if (response.statusCode != 200) {
        throw Exception('Failed to load categories');
      }
      List<String> categories = List<String>.from(response.data);
      return categories;
    } catch (e) {
      throw Exception('Error loading categories: $e');
    }
  }

  Future<List<Product>> loadProducts() async {
    Response response = await _dio.get('$_baseUrl/products');
    if (response.statusCode != 200) {
      throw Exception('Failed to load accounts');
    }

    List<Product> products = [];
    for (var p in response.data) {
      products.add(Product.fromJson(p));
    }
    return products;
  }

  Future<Product> getProductById(String id) async {
    Response response = await _dio.get('$_baseUrl/products/$id');
    if (response.statusCode == 200) {
      return Product.fromJson(response.data);
    } else {
      throw Exception('not able to get/fetch product, id: $id');
    }
  }

  Future<List<Product>> filterByNameAndCategory(
      String name, String category) async {
    try {
      final Map<String, dynamic> queryParams = {
        'name': name,
        'category': category != "All" ? category : "",
      };
      final response = await _dio.get('$_baseUrl/products/search',
          queryParameters: queryParams);
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        List<Product> products =
            data.map((product) => Product.fromJson(product)).toList();

        return products;
      } else {
        throw Exception("Failed to load products");
      }
    } catch (e) {
      print("Error fetching products: $e");
      rethrow;
    }
  }
}
