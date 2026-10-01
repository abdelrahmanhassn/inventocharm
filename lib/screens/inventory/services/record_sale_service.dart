import 'package:inventocharm/services/supabase_client.dart';

class RecordSaleService {
  static Future<void> recordSale(
    String customerName,
    String phoneNumber,
    List<Map<String, dynamic>> selectedItems,
  ) async {
    try {
      await supabase.rpc('record_sale', params: {
        'p_customer_name': customerName,
        'p_phone_number': phoneNumber,
        'p_items': selectedItems
            .map((item) => {
                  'id': item['docId'],
                  'quantity': item['saleQuantity'] as int? ?? 0,
                })
            .toList(),
      });
    } catch (e) {
      throw Exception('Error recording sale: $e');
    }
  }
}
