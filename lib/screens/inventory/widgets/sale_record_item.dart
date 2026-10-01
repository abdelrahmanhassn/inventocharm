import 'package:flutter/material.dart';

class SaleRecordItem extends StatelessWidget {
  final String itemName;
  final int quantity;
  final double price;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const SaleRecordItem({
    Key? key,
    required this.itemName,
    required this.quantity,
    required this.price,
    required this.onAdd,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double totalPrice = quantity * price;

    return ListTile(
      title: Text(itemName),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.remove),
          ),
          Text('$quantity'),
          IconButton(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      subtitle: Text(
          'Total Price: \$${totalPrice.toStringAsFixed(2)}'), // Display total price as a subtitle
    );
  }
}
