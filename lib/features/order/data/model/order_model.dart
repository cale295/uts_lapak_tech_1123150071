class OrderItemModel {
  final int productId;
  final String productName;
  final double price;
  final int quantity;
  final double subtotal;

  OrderItemModel({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.subtotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    final price =
        (json['price'] as num?)?.toDouble() ?? 0.0;

    final quantity =
        json['quantity'] as int? ??
        json['quantit'] as int? ??
        0;

    final apiSubtotal =
        (json['subtotal'] as num?)?.toDouble() ?? 0.0;

    final subtotal =
        apiSubtotal > 0
            ? apiSubtotal
            : price * quantity;

    return OrderItemModel(
      productId:
          json['product_id'] as int? ??
          json['id'] as int? ??
          0,

      productName:
          json['product_name'] as String? ??
          json['name'] as String? ??
          '',

      price: price,

      quantity: quantity,

      subtotal: subtotal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'price': price,
      'quantity': quantity,
      'subtotal': subtotal,
    };
  }
}

class OrderModel {
  final int id;
  final double totalAmount;
  final String status;
  final String shippingAddress;
  final String notes;
  final String paymentMethod;
  final List<OrderItemModel> items;
  final String createdAt;
  final String? vaNumber;
  final String? gopayDeeplink;

  OrderModel({
    required this.id,
    required this.totalAmount,
    required this.status,
    required this.shippingAddress,
    required this.notes,
    required this.paymentMethod,
    required this.items,
    required this.createdAt,
    this.vaNumber,
    this.gopayDeeplink,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final items =
        (json['items'] as List<dynamic>? ?? [])
            .map(
              (e) => OrderItemModel.fromJson(
                e as Map<String, dynamic>,
              ),
            )
            .toList();

    // Lebih aman hitung ulang total
    final calculatedTotal = items.fold<double>(
      0.0,
      (sum, item) => sum + item.subtotal,
    );

    final apiTotal =
        (json['total_amount'] as num?)?.toDouble() ?? 0.0;

    final totalAmount =
        apiTotal > 0 ? apiTotal : calculatedTotal;

    return OrderModel(
      id: json['id'] as int? ?? 0,

      totalAmount: totalAmount,

      status: json['status'] as String? ?? 'pending',

      shippingAddress:
          json['shipping_address'] as String? ?? '',

      notes: json['notes'] as String? ?? '',

      paymentMethod:
          json['payment_method'] as String? ?? '',

      items: items,

      createdAt:
          json['created_at'] as String? ?? '',

      vaNumber: json['va_number'] as String?,

      gopayDeeplink: json['gopay_deeplink'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'total_amount': totalAmount,
      'status': status,
      'shipping_address': shippingAddress,
      'notes': notes,
      'payment_method': paymentMethod,
      'items': items.map((e) => e.toJson()).toList(),
      'created_at': createdAt,
      'va_number': vaNumber,
      'gopay_deeplink': gopayDeeplink,
    };
  }
}