import 'package:inventocharm/services/pocketbase_client.dart';

class PocketBaseProductService {
  Future<void> addProduct(Map<String, dynamic> data) {
    return pocketBase.collection('products').create(body: {
      'name': data['name'],
      'description': data['description'],
      'price': data['price'],
      'quantity': data['quantity'],
      'image': data['image'],
      'category': data['category'],
    });
  }
}
