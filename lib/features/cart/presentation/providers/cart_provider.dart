import 'package:flutter/material.dart';

import '../../data/model/cart_model.dart';
import '../../data/repositories/cart_repository.dart';
import '../../domain/repositories/cart_repository_impl.dart';

enum CartStatus {
  initial,
  loading,
  loaded,
  error,
}

class CartProvider extends ChangeNotifier {
  final CartRepository _repository = CartRepositoryImpl();

  CartStatus _status = CartStatus.initial;

  CartModel? _cart;

  String? _error;

  bool _isAdding = false;

  CartStatus get status => _status;

  CartModel? get cart => _cart;

  String? get error => _error;

  bool get isAdding => _isAdding;

  List<CartItemModel> get items => _cart?.items ?? [];

  double get total => _cart?.total ?? 0;

  int get itemCount => _cart?.itemCount ?? 0;

  Future<void> fetchCart() async {
    try {
      _status = CartStatus.loading;
      _error = null;
      notifyListeners();

      final result = await _repository.getCart();

      _cart = result;

      _status = CartStatus.loaded;

      notifyListeners();
    } catch (e) {
      _status = CartStatus.error;

      _error = e.toString();

      notifyListeners();
    }
  }

  Future<bool> addToCart(
    int productId,
    int quantity,
  ) async {
    try {
      _isAdding = true;
      notifyListeners();

      await _repository.addToCart(
        productId,
        quantity,
      );

      await fetchCart();

      _isAdding = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isAdding = false;

      _error = e.toString();

      notifyListeners();

      return false;
    }
  }

  Future<void> updateItem(
    int cartItemId,
    int quantity,
  ) async {
    try {
      await _repository.updateCartItem(
        cartItemId,
        quantity,
      );

      await fetchCart();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> removeItem(int cartItemId) async {
    try {
      await _repository.removeCartItem(
        cartItemId,
      );

      if (_cart != null) {
        final updatedItems = _cart!.items
            .where((e) => e.id != cartItemId)
            .toList();

        final total = updatedItems.fold<double>(
          0,
          (sum, item) => sum + item.subtotal,
        );

        final itemCount = updatedItems.fold<int>(
          0,
          (sum, item) => sum + item.quantity,
        );

        _cart = CartModel(
          items: updatedItems,
          total: total,
          itemCount: itemCount,
        );
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    try {
      await _repository.clearCart();

      _cart = CartModel(
        items: [],
        total: 0,
        itemCount: 0,
      );

      _status = CartStatus.loaded;

      notifyListeners();
    } catch (e) {
      _error = e.toString();

      notifyListeners();
    }
  }
}