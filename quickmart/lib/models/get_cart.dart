import 'cart_item.dart';

class GetCart {
  final String id;
  final int quantity;

  GetCart({required this.id, required this.quantity});

  factory GetCart.fromJson(Map<String, dynamic> json) {
    return GetCart(
      id: json['id'] ?? '',
      quantity: json['quantity'] ?? 0,
    );
  }
  @override
  String toString() {
    return 'GetCart(id: $id, quantity: $quantity)';
  }
}
