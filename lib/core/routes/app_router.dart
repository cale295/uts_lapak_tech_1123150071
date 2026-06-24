import '../../main.dart';
import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/email_page.dart';
import '../../features/dasboard/presentation/pages/dashboard_page.dart';
import '../guards/auth_guard.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/order/presentation/pages/checkout_page.dart';
import '../../features/order/presentation/pages/my_order_page.dart';
import '../../features/order/data/model/order_model.dart';
import '../../features/order/presentation/pages/order_success_page.dart';
import '../../features/order/presentation/pages/payment_pending_page.dart';

class AppRouter {
  static const String splash         = '/';
  static const String login          = '/login';
  static const String register       = '/register';
  static const String verifyEmail    = '/verify-email';
  static const String dashboard      = '/dashboard';
  static const String cart           = '/cart';
  static const String checkout       = '/checkout';
  static const String paymentPending  = '/payment-pending';
  static const String orderSuccess   = '/order-success';
  static const String myOrders       = '/my-orders';



  static Map<String, WidgetBuilder> get routes => {
    splash:         (_) => const SplashPage(),
    login:          (_) => const LoginPage(),
    register:       (_) => const RegisterPage(),
    verifyEmail:    (_) => const VerifyEmailPage(),
    dashboard:      (_) => const AuthGuard(child: DashboardPage()),
    cart:           (_) => const CartPage(),
    checkout:       (_) => const CheckoutPage(),
    myOrders:       (_) => const MyOrdersPage(),
    paymentPending: (context) {
      final order = ModalRoute.of(context)!.settings.arguments as OrderModel;
      return PaymentPendingPage(order: order);
    },
    orderSuccess:   (context) {
      final order = ModalRoute.of(context)!.settings.arguments as OrderModel;
      return OrderSuccessPage(order: order);
    },

  };
}
