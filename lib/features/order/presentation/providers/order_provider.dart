import 'package:flutter/material.dart';

import '../../data/model/order_model.dart';
import '../../data/repositories/order_repository.dart';
import '../../domain/repositories/order_repository_impl.dart';

enum OrderStatus { initial, loading, success, error }

class OrderProvider extends ChangeNotifier {
  final OrderRepository _repository = OrderRepositoryImpl();


  OrderStatus _checkoutStatus = OrderStatus.initial;
  OrderModel? _lastOrder;      // ← order terakhir berhasil dibuat
  List<OrderModel> _orders = [];
  String? _error;


  Future<bool> checkout({
    required String shippingAddress,
    String? notes,
    required String paymentMethod,
  }) async {
    _setLoading();
    try {
      _lastOrder = await _repository.checkout(...);
      _checkoutStatus = OrderStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('...');
      return false;
    }
  }
}
