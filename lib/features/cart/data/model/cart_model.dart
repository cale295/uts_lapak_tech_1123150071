class CartProductModel {
  final int id;
  final String name;
  final double price;
  final String imageUrl;
  final String category;

  CartProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
  });

  factory CartProductModel.fromJson(Map<String, dynamic> json) {
    return CartProductModel(
      id: json['ID'] as int? ?? json['id'] as int? ?? 0,

      name: json['name'] as String? ?? '',

      price: (json['price'] as num?)?.toDouble() ?? 0.0,

      imageUrl: json['image_url'] as String? ?? '',

      category: json['category'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image_url': imageUrl,
      'category': category,
    };
  }
}

class CartItemModel {
  final int id;
  final int productId;
  final CartProductModel product;
  final int quantity;
  final double subtotal;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.product,
    required this.quantity,
    required this.subtotal,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final product = CartProductModel.fromJson(
      json['product'] as Map<String, dynamic>? ?? {},
    );

    final quantity = json['quantity'] as int? ?? json['quantit'] as int? ?? 0;

    final apiSubtotal = (json['subtotal'] as num?)?.toDouble() ?? 0.0;

    final subtotal = apiSubtotal > 0 ? apiSubtotal : product.price * quantity;

    return CartItemModel(
      id: json['ID'] as int? ?? json['id'] as int? ?? 0,

      productId: json['product_id'] as int? ?? 0,

      product: product,

      quantity: quantity,

      subtotal: subtotal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product': product.toJson(),
      'quantity': quantity,
      'subtotal': subtotal,
    };
  }
}

class CartModel {
  final List<CartItemModel> items;
  final double total;
  final int itemCount;

  CartModel({
    required this.items,
    required this.total,
    required this.itemCount,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>? ?? [])
        .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final total = items.fold<double>(0.0, (sum, item) => sum + item.subtotal);

    final itemCount = items.fold<int>(0, (sum, item) => sum + item.quantity);

    return CartModel(items: items, total: total, itemCount: itemCount);
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((e) => e.toJson()).toList(),
      'total': total,
      'item_count': itemCount,
    };
  }
}
