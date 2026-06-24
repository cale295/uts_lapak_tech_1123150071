import 'dart:async';
import 'package:flutter/material.dart';

import '../../data/model/order_model.dart';
import '../../data/repositories/order_repository.dart';
import '../../domain/repositories/order_repository_impl.dart';

enum OrderStatus { initial, loading, success, error }
enum PaymentCheckStatus { idle, checking, paid }

class OrderProvider extends ChangeNotifier {
  final OrderRepository _repository = OrderRepositoryImpl();

  OrderStatus _checkoutStatus = OrderStatus.initial;
  OrderStatus get checkoutStatus => _checkoutStatus;

  OrderModel? _lastOrder;      // ← order terakhir berhasil dibuat
  OrderModel? get lastOrder => _lastOrder;

  List<OrderModel> _orders = [];
  List<OrderModel> get orders => _orders;

  String? _error;
  String? get error => _error;

  PaymentCheckStatus _paymentCheckStatus = PaymentCheckStatus.idle;
  PaymentCheckStatus get paymentCheckStatus => _paymentCheckStatus;

  Timer? _paymentTimer;

  void _setLoading() {
    _checkoutStatus = OrderStatus.loading;
    _error = null;
    notifyListeners();
  }

  void _setError(String message) {
    _checkoutStatus = OrderStatus.error;
    _error = message;
    notifyListeners();
  }

  Future<bool> checkout({
    required String shippingAddress,
    String? notes,
    required String paymentMethod,
  }) async {
    _setLoading();
    try {
      _lastOrder = await _repository.checkout(
        shippingAddress: shippingAddress,
        notes: notes,
        paymentMethod: paymentMethod,
      );
      _checkoutStatus = OrderStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<void> fetchMyOrders() async {
    _checkoutStatus = OrderStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _orders = await _repository.getMyOrders();
      _checkoutStatus = OrderStatus.success;
    } catch (e) {
      _checkoutStatus = OrderStatus.error;
      _error = e.toString();
    }
    notifyListeners();
  }

  void startPaymentPolling(int orderId) {
    _paymentTimer?.cancel();
    _paymentCheckStatus = PaymentCheckStatus.idle;
    _paymentTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      checkPaymentStatus(orderId);
    });
  }

  void stopPaymentPolling() {
    _paymentTimer?.cancel();
    _paymentTimer = null;
  }

  Future<void> checkPaymentStatus(int orderId) async {
    if (_paymentCheckStatus == PaymentCheckStatus.checking) return;
    
    _paymentCheckStatus = PaymentCheckStatus.checking;
    notifyListeners();
    try {
      final order = await _repository.getOrderDetail(orderId);
      _lastOrder = order;
      if (order.status != 'pending') {
        _paymentCheckStatus = PaymentCheckStatus.paid;
      } else {
        _paymentCheckStatus = PaymentCheckStatus.idle;
      }
    } catch (e) {
      _paymentCheckStatus = PaymentCheckStatus.idle;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    stopPaymentPolling();
    super.dispose();
  }
}
