import 'cart_item.dart';

class Order {
  final String id;
  final String email;
  final List<CartItem> items;
  final double total;
  final DateTime date;

  Order({
    required this.id,
    required this.email,
    required this.items,
    required this.total,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'items': items.map((item) => item.toJson()).toList(),
      'total': total,
      'date': date.toIso8601String(),
    };
  }
}