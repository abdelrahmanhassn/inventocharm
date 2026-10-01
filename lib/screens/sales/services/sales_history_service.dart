import 'package:inventocharm/services/pocketbase_client.dart';

class SalesDataService {
  static Future<List<Map<String, dynamic>>> fetchSalesData() async {
    try {
      final rows = await pocketBase.collection('sales').getFullList();

      print('Fetched ${rows.length} records from the "sales" collection');

      List<Map<String, dynamic>> salesData = [];

      for (final record in rows) {
        final doc = record.data;
        final date = doc['date'];
        if (date != null) {
        } else {
          print('Sale is missing a date field.');
        }

        final total = doc['total'];
        double parsedTotal = 0.0;
        if (total != null) {
          parsedTotal = double.tryParse(total.toString()) ?? 0.0;
        } else {
          print('Sale is missing a total field.');
        }

        final items = doc['items'];
        List<Map<String, dynamic>> itemList = [];
        if (items != null) {
          itemList = List<Map<String, dynamic>>.from(items);
        } else {
          print('Sale is missing an items field.');
        }

        if (date != null && total != null && items != null) {
          print('Sale items: $itemList');

          Map<String, dynamic> data = {
            'date': doc['date'],
            'total': parsedTotal,
            'items': itemList,
          };
          salesData.add(data);
        }
      }

      print('Fetched sales data: $salesData');

      return salesData;
    } catch (e) {
      print('Error fetching sales data: $e');
      throw e;
    }
  }
}
