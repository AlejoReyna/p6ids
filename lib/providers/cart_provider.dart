// providers/cart_provider.dart
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/cart_item.dart';

class CartProvider with ChangeNotifier {
  Map<int, CartItem> _items = {};
  
  Map<int, CartItem> get items => {..._items};
  
  int get itemCount => _items.length;

  int get totalItems {
    return _items.values.fold(0, (sum, item) => sum + item.quantity);
  }

  double get totalAmount {
    return _items.values.fold(0.0, 
      (sum, item) => sum + (item.product.price * item.quantity));
  }

  bool isInCart(int productId) {
    return _items.containsKey(productId);
  }

  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      // Si el producto ya está en el carrito, incrementa la cantidad
      _items.update(
        product.id,
        (existingCartItem) => CartItem(
          product: existingCartItem.product,
          quantity: existingCartItem.quantity + 1,
        ),
      );
    } else {
      // Si no está en el carrito, agrégalo con cantidad 1
      _items.putIfAbsent(
        product.id,
        () => CartItem(product: product),
      );
    }
    notifyListeners();
  }

  void removeItem(int productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void decrementItem(int productId) {
    if (!_items.containsKey(productId)) return;
    
    if (_items[productId]!.quantity > 1) {
      // Si hay más de uno, decrementa la cantidad
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          product: existingCartItem.product,
          quantity: existingCartItem.quantity - 1,
        ),
      );
    } else {
      // Si solo hay uno, remueve el item del carrito
      _items.remove(productId);
    }
    notifyListeners();
  }

  void updateItemQuantity(int productId, int quantity) {
    if (!_items.containsKey(productId)) return;
    
    if (quantity > 0) {
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          product: existingCartItem.product,
          quantity: quantity,
        ),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  Order createOrder(String email) {
    return Order(
      id: const Uuid().v4(),
      email: email,
      items: _items.values.toList(),
      total: totalAmount,
      date: DateTime.now(),
    );
  }

  void clear() {
    _items = {};
    notifyListeners();
  }

  // Método útil para debugging
  void printCartContents() {
    print('\nCarrito actual:');
    if (_items.isEmpty) {
      print('El carrito está vacío');
    } else {
      _items.forEach((key, item) {
        print('${item.product.title} - Cantidad: ${item.quantity} - Precio unitario: \$${item.product.price} - Subtotal: \$${item.product.price * item.quantity}');
      });
      print('Total: \$${totalAmount.toStringAsFixed(2)}');
    }
  }
}