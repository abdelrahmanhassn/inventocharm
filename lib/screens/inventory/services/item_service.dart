import 'package:inventocharm/models/item.dart';
import 'package:inventocharm/services/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DuplicateItemException implements Exception {
  const DuplicateItemException();

  @override
  String toString() => 'An item with this barcode already exists.';
}

class ItemService {
  String get _ownerId {
    final id = supabase.auth.currentUser?.id;
    if (id == null) throw StateError('Sign in before managing items.');
    return id;
  }

  Future<void> addItem(Item item) async {
    final ownerId = _ownerId;
    final normalizedCode = item.code?.trim();

    if (normalizedCode != null && normalizedCode.isNotEmpty) {
      final existing = await supabase
          .from('items')
          .select('id')
          .eq('owner_id', ownerId)
          .eq('code', normalizedCode)
          .maybeSingle();
      if (existing != null) throw const DuplicateItemException();
    }

    try {
      await supabase.from('items').insert({
        'owner_id': ownerId,
        'name': item.name.trim(),
        'price': item.price,
        'quantity': item.quantity,
        'image': item.image,
        'description': item.description.trim(),
        'cost': item.cost,
        'code': (normalizedCode?.isEmpty ?? true) ? null : normalizedCode,
      });
    } on PostgrestException catch (error) {
      if (error.code == '23505') throw const DuplicateItemException();
      rethrow;
    }
  }

  Future<void> updateItem(Item item) async {
    await supabase.from('items').update(item.toJson()).eq('id', item.id);
  }

  Future<void> deleteItem(String itemId) async {
    final deleted = await supabase
        .from('items')
        .delete()
        .eq('id', itemId)
        .eq('owner_id', _ownerId)
        .select('id');
    if (deleted.isEmpty) {
      throw StateError(
        'Item was not deleted. It may already be deleted, or your Supabase '
        'row-level security policy may not allow deleting it.',
      );
    }
  }

  Future<List<Item>> getItems() async {
    final rows = await supabase
        .from('items')
        .select()
        .eq('owner_id', _ownerId)
        .order('created_at', ascending: false);
    return rows.map(Item.fromJson).toList();
  }

  Future<Item?> getItem(String itemId) async {
    final row = await supabase
        .from('items')
        .select()
        .eq('id', itemId)
        .eq('owner_id', _ownerId)
        .maybeSingle();
    return row == null ? null : Item.fromJson(row);
  }
}
