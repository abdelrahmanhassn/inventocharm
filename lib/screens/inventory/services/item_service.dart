import 'package:inventocharm/services/supabase_client.dart';

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
      await supabase.from('items').insert({
        'owner_id': supabase.auth.currentUser!.id,
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
      await supabase.from('items').update({
        if (name != null) 'name': name,
        if (price != null) 'price': price,
        if (quantity != null) 'quantity': quantity,
        if (image != null) 'image': image,
        if (description != null) 'description': description,
        if (cost != null) 'cost': cost,
      }).eq('id', itemId);
    } catch (e) {
      print('Error updating item: $e');
    }
  }

  // Delete an item
  Future<void> deleteItem(String itemId) async {
    try {
      await supabase.from('items').delete().eq('id', itemId);
    } catch (e) {
      print('Error deleting item: $e');
    }
  }

  // Get all items
  Future<List<Map<String, dynamic>>> getItems() async {
    final rows = await supabase.from('items').select();
    return rows;
  }

  Future<Map<String, dynamic>> getItem(String itemId) async {
    return await supabase.from('items').select().eq('id', itemId).single();
  }
}
