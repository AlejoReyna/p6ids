import 'dart:isolate';
import 'package:p6ids/services/api_service.dart';
import 'package:p6ids/models/product.dart';

class IsolateManager {
  static Future<List<Product>> fetchProductsInIsolate() async {
    final ReceivePort receivePort = ReceivePort();
    await Isolate.spawn(_isolateEntryPoint, receivePort.sendPort);

    // Espera la respuesta del isolate
    final List<Product> products = await receivePort.first;
    return products;
  }

  static void _isolateEntryPoint(SendPort sendPort) async {
    final apiService = ApiService();
    List<Product> products = await apiService.fetchProducts();
    Isolate.exit(sendPort, products);
  }

  static Future<List<Product>> searchProductsInIsolate(String query) async {
    final ReceivePort receivePort = ReceivePort();
    await Isolate.spawn(_searchIsolateEntryPoint, [receivePort.sendPort, query]);

    // Espera la respuesta del isolate
    final List<Product> products = await receivePort.first;
    return products;
  }

  static void _searchIsolateEntryPoint(List<dynamic> args) async {
    SendPort sendPort = args[0];
    String query = args[1];

    final apiService = ApiService();
    List<Product> products = await apiService.searchProducts(query);
    Isolate.exit(sendPort, products);
  }
}