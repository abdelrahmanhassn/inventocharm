import 'package:inventocharm/models/item.dart';
import 'package:inventocharm/services/supabase_client.dart';
import 'package:inventocharm/screens/inventory/services/item_service.dart';

class DashboardData {
  static Future<Map<String, String>> fetchData() async {
    final items = await ItemService().getItems();
    final ownerId = supabase.auth.currentUser?.id;
    if (ownerId == null) throw StateError('Sign in before loading dashboard.');

    final sales = await supabase
        .from('sales')
        .select('total, items')
        .eq('owner_id', ownerId);

    return calculate(items: items, sales: sales);
  }

  static Map<String, String> calculate({
    required List<Item> items,
    required List<Map<String, dynamic>> sales,
  }) {
    var totalItemCostCents = 0;
    var totalPricesCents = 0;

    for (final item in items) {
      totalItemCostCents += (item.cost * 100).round() * item.quantity;
      totalPricesCents += (item.price * 100).round() * item.quantity;
    }

    var totalSalesCents = 0;
    var totalSalesProfitCents = 0;
    var salesProfitAvailable = true;

    for (final sale in sales) {
      totalSalesCents += _toCents(sale['total']);

      final saleItems = sale['items'];
      if (saleItems is! List) {
        throw const FormatException('Sale items must be a list.');
      }

      for (final rawItem in saleItems) {
        if (rawItem is! Map) {
          throw const FormatException('Sale item must be an object.');
        }

        final quantity = int.tryParse(rawItem['quantity']?.toString() ?? '');
        if (quantity == null || quantity < 0) {
          throw const FormatException('Sale item quantity is invalid.');
        }

        final priceCents = _toCents(rawItem['price']);
        final cost = rawItem['cost'];
        if (cost == null) {
          salesProfitAvailable = false;
          continue;
        }
        totalSalesProfitCents +=
            (priceCents - _toCents(cost)) * quantity;
      }
    }

    return {
      'totalProducts': items.length.toString(),
      'totalItemCost': (totalItemCostCents / 100).toStringAsFixed(2),
      'totalPrices': (totalPricesCents / 100).toStringAsFixed(2),
      'profit':
          ((totalPricesCents - totalItemCostCents) / 100).toStringAsFixed(2),
      'completedSales': sales.length.toString(),
      'salesRevenue': (totalSalesCents / 100).toStringAsFixed(2),
      'salesProfit': salesProfitAvailable
          ? (totalSalesProfitCents / 100).toStringAsFixed(2)
          : 'N/A',
    };
  }

  static int _toCents(dynamic value) {
    if (value is num) return (value * 100).round();
    final parsed = double.tryParse(value?.toString() ?? '');
    if (parsed == null) {
      throw FormatException('Invalid monetary value: $value');
    }
    return (parsed * 100).round();
  }
}
