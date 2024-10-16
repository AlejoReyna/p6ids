import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:p6ids/models/product.dart';

class ApiService {
  static const String baseUrl = 'https://fakestoreapi.com';

  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));

    if (response.statusCode == 200) {
      List<dynamic> productsJson = jsonDecode(response.body);
      return productsJson.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  }

  Future<Product> fetchProductById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/products/$id'));

    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load product: ${response.statusCode}');
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    // Note: Fake Store API doesn't have a search endpoint, so we're fetching all products and filtering client-side
    final response = await http.get(Uri.parse('$baseUrl/products'));

    if (response.statusCode == 200) {
      List<dynamic> productsJson = jsonDecode(response.body);
      List<Product> allProducts = productsJson.map((json) => Product.fromJson(json)).toList();
      return allProducts.where((product) => 
        product.title.toLowerCase().contains(query.toLowerCase()) ||
        product.description.toLowerCase().contains(query.toLowerCase())
      ).toList();
    } else {
      throw Exception('Failed to search products: ${response.statusCode}');
    }
  }
}