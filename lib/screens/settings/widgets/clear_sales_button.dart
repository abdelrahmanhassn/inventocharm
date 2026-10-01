import 'package:flutter/material.dart';
import 'package:inventocharm/services/supabase_client.dart';
import 'package:inventocharm/components/constants/colors.dart';

class ClearSalesButton extends StatelessWidget {
  const ClearSalesButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        _clearSalesCollection(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: CustomColors.primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: const Text('Clear Sales Collection'),
    );
  }

  Future<void> _clearSalesCollection(BuildContext context) async {
    try {
      final rows = await supabase.from('sales').select('id');

      if (rows.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No documents found in the sales collection.'),
          ),
        );
        return;
      }

      await supabase.from('sales').delete().not('id', 'is', null);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sales collection cleared successfully.'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error clearing sales collection: $e'),
        ),
      );
    }
  }
}
