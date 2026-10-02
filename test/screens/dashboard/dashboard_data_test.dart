import 'package:flutter_test/flutter_test.dart';
import 'package:inventocharm/models/item.dart';
import 'package:inventocharm/screens/dashboard/dashboard_data.dart';

void main() {
  group('DashboardData.calculate', () {
    test('calculates stock value and completed sale metrics separately', () {
      final data = DashboardData.calculate(
        items: [
          _item(id: 'item-1', price: 10.50, cost: 4.25, quantity: 3),
          _item(id: 'item-2', price: 2.10, cost: 1, quantity: 2),
        ],
        sales: [
          {
            'total': 21.00,
            'items': [
              {'price': '10.50', 'cost': '4.25', 'quantity': '2'},
            ],
          },
        ],
      );

      expect(data['totalProducts'], '2');
      expect(data['totalItemCost'], '14.75');
      expect(data['totalPrices'], '35.70');
      expect(data['profit'], '20.95');
      expect(data['completedSales'], '1');
      expect(data['salesRevenue'], '21.00');
      expect(data['salesProfit'], '12.50');
    });

    test('does not estimate historical sales profit without cost snapshots',
        () {
      final data = DashboardData.calculate(
        items: const [],
        sales: [
          {
            'total': '12.50',
            'items': [
              {'price': '12.50', 'quantity': '1'},
            ],
          },
        ],
      );

      expect(data['salesRevenue'], '12.50');
      expect(data['salesProfit'], 'N/A');
    });
  });
}

Item _item({
  required String id,
  required double price,
  required double cost,
  required int quantity,
}) {
  return Item(
    id: id,
    ownerId: 'owner',
    name: id,
    description: '',
    price: price,
    cost: cost,
    quantity: quantity,
  );
}
