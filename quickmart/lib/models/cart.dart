class Cart {
  final String productId;
  late final int quantity;
  Cart({
    required this.productId,
    required this.quantity,
  });
  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      productId: json['productId'] as String,
      quantity: json['quantity'] as int,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
    };
  }
}
