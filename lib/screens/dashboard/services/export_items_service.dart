import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:inventocharm/services/supabase_client.dart';

class ExportItemsService {
  Future<String?> exportDataToCsv() async {
    try {
      final dataRows = await supabase.from('items').select();

      final List<List<dynamic>> csvRows = [];

      // Add header row with field names
      final List<dynamic> headerRow = [
        'Item Name',
        'Price',
        'Quantity',
        'Cost',
      ];
      csvRows.add(headerRow);

      for (final data in dataRows) {
        final List<dynamic> saleInfo = [
          data['name'],
          data['price'],
          data['quantity'],
          data['cost'],
        ];

        csvRows.add(saleInfo);
      }

      final Directory? directory = await getExternalStorageDirectory();
      if (directory == null) {
        return null;
      }

      final String filePath = '${directory.path}/items.csv';
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
