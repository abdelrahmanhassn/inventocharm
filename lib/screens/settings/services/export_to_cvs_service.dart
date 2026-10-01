import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:inventocharm/services/pocketbase_client.dart';

class ExportCsvService {
  Future<String?> exportDataToCsv() async {
    try {
      final dataRows = await pocketBase.collection('sales').getFullList();

      final List<List<dynamic>> csvRows = [];

      // Add header row with field names
      final List<dynamic> headerRow = [
        'Customer Name',
        'Phone Number',
        'Total',
        'Date',
        'Item Name',
        'Quantity',
        'Price',
      ];
      csvRows.add(headerRow);

      for (final record in dataRows) {
        final data = record.data;
        final List<dynamic> saleInfo = [
          data['customerName'],
          data['phoneNumber'],
          data['total'],
          DateFormat.yMd().add_jm().format(
                DateTime.tryParse(data['date'].toString()) ?? DateTime.now(),
              ),
        ];

        final items = data['items'] as List?;
        if (items != null) {
          for (var item in items) {
            final List<dynamic> row =
                List.from(saleInfo); // Copy saleInfo to avoid modifying it
            row.addAll([item['itemName'], item['quantity'], item['price']]);
            csvRows.add(row);
          }
        } else {
          csvRows.add(saleInfo); // Add saleInfo even if there are no items
        }
      }

      final Directory? directory = await getExternalStorageDirectory();
      if (directory == null) {
        return null;
      }

      final String filePath = '${directory.path}/sales.csv';
      final File file = File(filePath);

      String csvContent = const ListToCsvConverter().convert(csvRows);
      await file.writeAsString(csvContent);

      return filePath;
    } catch (e) {
      print('Error exporting data to CSV: $e');
      return null;
    }
  }
}
