import 'package:flutter/material.dart';
import 'package:inventocharm/components/constants/colors.dart';
import 'package:inventocharm/components/my_text_field.dart';
import 'package:inventocharm/screens/inventory/services/record_sale_service.dart';
import 'package:inventocharm/screens/inventory/widgets/sale_record_item.dart';

class RecordSaleDialog extends StatefulWidget {
  final List<Map<String, dynamic>> selectedItems;
  final Function(List<Map<String, dynamic>>) onSaleRecorded;

  RecordSaleDialog({required this.selectedItems, required this.onSaleRecorded});

  @override
  _RecordSaleDialogState createState() => _RecordSaleDialogState();
}

class _RecordSaleDialogState extends State<RecordSaleDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
  }

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
                hintText: "Customer Name",
                obscureText: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter customer name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              MyTextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                obscureText: false,
                hintText: "Phone Number",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              for (var selectedItem in widget.selectedItems)
                SaleRecordItem(
                  itemName: selectedItem['name'],
                  quantity: (selectedItem['saleQuantity'] as int?) ?? 0,
                  price: double.tryParse(selectedItem['price'] ?? '0') ?? 0.0,
                  onAdd: () {
                    setState(() {
                      var currentItemIndex = widget.selectedItems.indexWhere(
                          (item) => item['name'] == selectedItem['name']);
                      if (currentItemIndex != -1) {
                        var currentSaleQuantity =
                            (widget.selectedItems[currentItemIndex]
                                    ['saleQuantity'] as int?) ??
                                0;
                        widget.selectedItems[currentItemIndex]['saleQuantity'] =
                            currentSaleQuantity + 1;
                      } else {
                        widget.selectedItems
                            .add({...selectedItem, 'saleQuantity': 1});
                      }
                    });
                  },
                  onRemove: () {
                    setState(() {
                      var currentItemIndex = widget.selectedItems.indexWhere(
                          (item) => item['name'] == selectedItem['name']);
                      if (currentItemIndex != -1) {
                        var currentSaleQuantity =
                            (widget.selectedItems[currentItemIndex]
                                    ['saleQuantity'] as int?) ??
                                0;
                        if (currentSaleQuantity > 0) {
                          widget.selectedItems[currentItemIndex]
                              ['saleQuantity'] = currentSaleQuantity - 1;
                          if (currentSaleQuantity == 1) {
                            widget.selectedItems.removeAt(currentItemIndex);
                          }
                        }
                      }
                    });
                  },
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(CustomColors.error),
          ),
          onPressed: () {
            widget.selectedItems.clear();
            Navigator.pop(context);
          },
          child: Text(
            'Cancel',
            style: TextStyle(fontSize: 13, color: CustomColors.white),
          ),
        ),
        TextButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(CustomColors.success),
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _recordSale();
            }
          },
          child: Text(
            'Record',
            style: TextStyle(fontSize: 13, color: CustomColors.white),
          ),
        ),
      ],
    );
  }

  void _recordSale() async {
    try {
      if (widget.selectedItems.isEmpty) {
        // Handle case when no items are selected
        return;
      }

      // Get customer details
      String customerName = _nameController.text;
      String phoneNumber = _phoneController.text;

      // Record sale using the PocketBase service.
      await RecordSaleService.recordSale(
        customerName,
        phoneNumber,
        widget.selectedItems,
      );

      // Update UI and close dialog
      widget.onSaleRecorded(widget.selectedItems);
      widget.selectedItems.clear();
      Navigator.pop(context);
    } catch (e) {
      print('Error recording sale: $e');
    }
  }
}
