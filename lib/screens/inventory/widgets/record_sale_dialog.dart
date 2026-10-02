import 'package:flutter/material.dart';

import 'package:inventocharm/components/constants/colors.dart';
import 'package:inventocharm/components/my_text_field.dart';
import 'package:inventocharm/models/item.dart';
import 'package:inventocharm/screens/inventory/services/record_sale_service.dart';
import 'package:inventocharm/screens/inventory/widgets/sale_record_item.dart';

class RecordSaleDialog extends StatefulWidget {
  const RecordSaleDialog({
    super.key,
    required this.selectedItems,
    required this.onSaleRecorded,
  });

  final List<Item> selectedItems;
  final void Function(List<Item>) onSaleRecorded;

  @override
  State<RecordSaleDialog> createState() => _RecordSaleDialogState();
}

/// Wrapper that tracks how many units of a given item are being sold.
class _SaleLine {
  final Item item;
  int quantity;

  _SaleLine({required this.item, this.quantity = 1});
}

class _RecordSaleDialogState extends State<RecordSaleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  /// Local state, doesn't mutate widget.selectedItems.
  late final List<_SaleLine> _lines =
      widget.selectedItems.map((item) => _SaleLine(item: item)).toList();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: CustomColors.grey,
      title: const Text('Record Sale'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              MyTextField(
                controller: _nameController,
                keyboardType: TextInputType.name,
                hintText: 'Customer Name',
                obscureText: false,
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Please enter customer name'
                    : null,
              ),
              const SizedBox(height: 8),
              MyTextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                obscureText: false,
                hintText: 'Phone Number',
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Please enter phone number'
                    : null,
              ),
              const SizedBox(height: 20),
              for (final line in _lines)
                SaleRecordItem(
                  itemName: line.item.name,
                  quantity: line.quantity,
                  price: line.item.price,
                  onAdd: () => setState(() => line.quantity++),
                  onRemove: () => setState(() {
                    if (line.quantity <= 1) {
                      _lines.remove(line);
                    } else {
                      line.quantity--;
                    }
                  }),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: CustomColors.error,
          ),
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(fontSize: 13, color: CustomColors.white),
          ),
        ),
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: CustomColors.success,
          ),
          onPressed: _isSubmitting ? null : _recordSale,
          child: _isSubmitting
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text(
                  'Record',
                  style: TextStyle(fontSize: 13, color: CustomColors.white),
                ),
        ),
      ],
    );
  }

  Future<void> _recordSale() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_lines.isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      await RecordSaleService.recordSale(
        _nameController.text.trim(),
        _phoneController.text.trim(),
        [
          for (final line in _lines)
            {
              'id': line.item.id,
              'name': line.item.name,
              'price': line.item.price,
              'saleQuantity': line.quantity,
            },
        ],
      );

      if (!mounted) return;
      widget.onSaleRecorded(widget.selectedItems);
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not record sale: $error')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
