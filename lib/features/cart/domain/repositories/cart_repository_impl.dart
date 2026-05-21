import '../../data/model/cart_model.dart';
import '../../data/repositories/cart_repository.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/dio_client.dart';

class CartRepositoryImpl implements CartRepository {
  @override
  Future<CartModel> getCart() async {
    final response = await DioClient.instance.get(ApiConstants.cart);
    final data = response.data['data'] as Map<String, dynamic>;
    return CartModel.fromJson(data);
  }

  @override
  Future<void> addToCart(int productId, int quantity) async {
    await DioClient.instance.post(
      ApiConstants.cart,
      data: {'product_id': productId, 'quantity': quantity},
    );
  }

  @override
  Future<void> updateCartItem(int cartItemId, int quantity) async {
    await DioClient.instance.put(
      '${ApiConstants.cart}/$cartItemId', // /v1/cart/1
      data: {'quantity': quantity},
    );
  }

  @override
  Future<void> removeCartItem(int cartItemId) async {
    await DioClient.instance.delete('${ApiConstants.cart}/$cartItemId');
  }

  @override
  Future<void> clearCart() async {
    await DioClient.instance.delete(ApiConstants.cart);
  }
}
