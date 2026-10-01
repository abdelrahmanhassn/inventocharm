import 'package:inventocharm/services/supabase_client.dart';

class DashboardData {
  static Future<Map<String, String>> fetchData() async {
    try {
      final rows = await supabase.from('items').select();

      int totalProducts = rows.length;
      int totalItemCost = 0;
      int totalPrices = 0;

      for (final data in rows) {
        if (data['cost'] != null &&
            data['price'] != null &&
            data['quantity'] != null) {
          try {
            final quantity = int.parse(data['quantity'].toString());
            totalItemCost += int.parse(data['cost'].toString()) * quantity;
            totalPrices += int.parse(data['price'].toString()) * quantity;
          } catch (error) {
            print('Error parsing item data: $error');
          }
        }
      }

      int profit = totalPrices - totalItemCost;

      return {
        'totalProducts': totalProducts.toString(),
        'totalItemCost': totalItemCost.toString(),
        'totalPrices': totalPrices.toString(),
        'profit': profit.toString(),
      };
    } catch (error) {
      print('Error fetching data: $error');
      return {
        'totalProducts': '0',
        'totalItemCost': '0',
        'totalPrices': '0',
        'profit': '0',
      };
    }
  }
}
