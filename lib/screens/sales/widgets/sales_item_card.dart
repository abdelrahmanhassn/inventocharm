import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:inventocharm/components/constants/colors.dart';

class SalesItemCard extends StatelessWidget {
  final String customerName;
  final Map<String, dynamic> data;

  const SalesItemCard({
    Key? key,
    required this.data,
    required this.customerName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items =
        data['items']?.cast<Map<String, dynamic>>() ?? [];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 8, left: 8),
      child: Material(
        elevation: 3,
        color: CustomColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            _showItemsDialog(context, items, customerName, data);
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            FontAwesomeIcons.handHoldingDollar,
                            color: CustomColors.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: CustomColors.secondaryColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(customerName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style:
                                    Theme.of(context).textTheme.titleMedium!),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        icon: FontAwesomeIcons.calendarDays,
                        text: _formatDate(data['date']),
                        context: context,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        icon: FontAwesomeIcons.moneyBill,
                        text:
                            '\$${(double.tryParse(data['total'].toString()) ?? 0).toStringAsFixed(2)}',
                        context: context,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(dynamic value) {
    if (value != null) {
      final DateTime? dateTime = DateTime.tryParse(value.toString());
      if (dateTime == null) return 'No Date';
      final DateFormat formatter =
          DateFormat('EEEE, dd MMMM yyyy \'at\' HH:mm');
      return formatter.format(dateTime);
    } else {
      return 'No Date';
    }
  }

  void _showItemsDialog(
    BuildContext context,
    List<Map<String, dynamic>> items,
    String customerName,
    Map<String, dynamic> data,
  ) {
    final double total = data['total'] ?? 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ordered by: $customerName',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Phone Number: ${data['phoneNumber']}',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 8),
            Text(
              'Date: ${_formatDate(data['date'])}',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 8),
            Text(
              'Total: \$ ${total.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 8),
            const Text(
              'Items:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        icon: const Icon(FontAwesomeIcons.fileInvoiceDollar),
        content: SizedBox(
          height: 300.0,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.map((item) {
                final String itemName = item['itemName'] ?? 'No Item Name';
                int? quantity;

                final quantityString = item['quantity'];
                if (quantityString != null) {
                  quantity = int.tryParse(quantityString);
                }

                final priceString = item['price'] ?? '0';
                final price =
                    double.tryParse(priceString)?.toStringAsFixed(2) ?? '0.00';

                final displayedQuantity = quantity ?? 0;

                return ListTile(
                  title: Text(
                    itemName,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quantity: $displayedQuantity',
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Price: \$ $price',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    required BuildContext context,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: CustomColors.primaryColor,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: Theme.of(context).textTheme.labelMedium,
        ),
      ],
    );
  }
}
