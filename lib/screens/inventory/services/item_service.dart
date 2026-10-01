import 'package:inventocharm/services/pocketbase_client.dart';

class ItemService {
  // Add a new item
  Future<void> addItem({
    required String name,
    required String price,
    required String quantity,
    required String image,
    required String description,
    required String cost,
  }) async {
    try {
      await pocketBase.collection('items').create(body: {
        'name': name,
        'price': price,
        'quantity': quantity,
        'image': image,
        'description': description,
        'cost': cost,
      });
    } catch (e) {
      print('Error adding item: $e');
    }
  }

  // Update an existing item
  Future<void> updateItem(
    String itemId, {
    String? name,
    String? price,
    String? quantity,
    String? image,
    String? description,
    String? cost,
  }) async {
    try {
      await pocketBase.collection('items').update(itemId, body: {
        if (name != null) 'name': name,
        if (price != null) 'price': price,
        if (quantity != null) 'quantity': quantity,
        if (image != null) 'image': image,
        if (description != null) 'description': description,
        if (cost != null) 'cost': cost,
      });
    } catch (e) {
      print('Error updating item: $e');
    }
  }

  // Delete an item
  Future<void> deleteItem(String itemId) async {
    try {
      await pocketBase.collection('items').delete(itemId);
    } catch (e) {
      print('Error deleting item: $e');
    }
  }

  // Get all items
  Future<List<Map<String, dynamic>>> getItems() async {
    final rows = await pocketBase.collection('items').getFullList();
    return rows.map((row) => {'id': row.id, ...row.data}).toList();
  }

  Future<Map<String, dynamic>> getItem(String itemId) async {
    final row = await pocketBase.collection('items').getOne(itemId);
    return {'id': row.id, ...row.data};
  }
}
