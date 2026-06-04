import '../../main.dart';
import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/email_page.dart';
import '../../features/dasboard/presentation/pages/dashboard_page.dart';
import '../guards/auth_guard.dart';

class AppRouter {
  static const String splash      = '/';
  static const String login       = '/login';
  static const String register    = '/register';
  static const String verifyEmail = '/verify-email';
  static const String dashboard   = '/dashboard';
  static const String cart         = '/cart';
  static const String checkout     = '/checkout';
  static const String orderSuccess = '/order-success';
  static const String myOrders     = '/my-orders';



  static Map<String, WidgetBuilder> get routes => {
    splash:      (_) => const SplashPage(),
    login:       (_) => const LoginPage(),
    register:    (_) => const RegisterPage(),
    verifyEmail: (_) => const VerifyEmailPage(),
    dashboard:   (_) => const AuthGuard(child: DashboardPage()),
    cart:         (_) => const CartPage(),
    checkout:     (_) => const CheckoutPage(),
    myOrders:     (_) => const MyOrdersPage(),
    orderSuccess: (context) {
      final order = ModalRoute.of(context)!.settings.arguments as OrderModel;
      return OrderSuccessPage(order: order);
    },

  };
}
