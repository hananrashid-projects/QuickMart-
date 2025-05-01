class CartItem {
  String productId;
  String productName;
  int quantity;
  double unitPrice;

  CartItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  factory CartItem.fromJson(Map<String, dynamic> map) {
    return CartItem(
      productId: map['productId'] as String,
      productName: map['productName'] as String,
      quantity: map['quantity'] as int,
      unitPrice: map['unitPrice'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
    };
  }

  double calculateTotalPrice() {
    return quantity * unitPrice;
  }
}
