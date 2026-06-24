class ApiConstants {
  static const String baseUrl = "https://rosaria-digitate-archly.ngrok-free.dev/v1";
  // Auth endpoints
  static const String verifyToken = '/auth/verify-token';
 
  // Product endpoints
  static const String products = '/products';
 
  // Timeout
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;

  // Cart endpoints
  static const String cart = '/cart';


  // Order endpoints
  static const String orders = '/orders';
  static const String checkout = '/orders/checkout';

}
