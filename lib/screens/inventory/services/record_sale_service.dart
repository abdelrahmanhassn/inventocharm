import 'package:inventocharm/services/pocketbase_client.dart';

class RecordSaleService {
  static Future<void> recordSale(
    String customerName,
    String phoneNumber,
    List<Map<String, dynamic>> selectedItems,
  ) async {
    try {
      final List<Map<String, dynamic>> itemRows = [];
      double totalSalePrice = 0;

      for (var item in selectedItems) {
        String? docId = item['docId'];
        if (docId != null) {
          final row = (await pocketBase.collection('items').getOne(docId)).data;
          itemRows.add(row);
          totalSalePrice += (item['saleQuantity'] as int? ?? 0) *
              double.parse(row['price'].toString());
        }
      }

      final List<Map<String, dynamic>> saleRecords = [];

      for (int i = 0; i < selectedItems.length; i++) {
        var item = selectedItems[i];
        var itemRow = itemRows[i];

        if (itemRow.isNotEmpty) {
          int currentQuantity =
              int.tryParse(itemRow['quantity'].toString()) ?? 0;

          int saleQuantity = item['saleQuantity'] as int? ?? 0;
          int newQuantity = currentQuantity - saleQuantity;

          if (newQuantity < 0) {
            throw Exception(
                'Sale quantity exceeds available quantity for item ${item['name']}');
          }

          saleRecords.add({
            'itemName': item['name'],
            'quantity': saleQuantity.toString(),
            'price': itemRow['price'].toString(),
          });

          await pocketBase.collection('items').update(
            item['docId'],
            body: {'quantity': newQuantity.toString()},
          );
        } else {
          throw Exception('Item not found: ${item['docId']}');
        }
      }

      await pocketBase.collection('sales').create(body: {
        'date': DateTime.now().toIso8601String(),
        'customerName': customerName,
        'phoneNumber': phoneNumber,
        'total': totalSalePrice, // Include the total price field
        'items': saleRecords,
      });
    } catch (e) {
      throw Exception('Error recording sale: $e');
    }
  }
}
