import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inventocharm/components/constants/colors.dart';
import 'package:inventocharm/screens/inventory/services/item_service.dart';
import 'package:inventocharm/screens/inventory/widgets/material_item_card.dart';

class DetailsScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const DetailsScreen({Key? key, required this.data}) : super(key: key);

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late TextEditingController quantityController;

  @override
  void initState() {
    super.initState();
    quantityController = TextEditingController(text: widget.data['quantity']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'editQuantity',
                child: Row(
                  children: [
                    Icon(FontAwesomeIcons.edit, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'Edit Quantity',
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(FontAwesomeIcons.trash, color: CustomColors.error),
                    SizedBox(width: 8),
                    Text(
                      'Delete Item',
                    ),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              if (value == 'editQuantity') {
                // Show dialog to edit quantity
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Edit Quantity"),
                      content: TextField(
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Enter new quantity',
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () async {
                            // Update the item quantity in PocketBase.
                            try {
                              // Parse the new quantity
                              int newQuantity =
                                  int.parse(quantityController.text);

                              // Update the item in PocketBase with the new quantity.
                              await ItemService().updateItem(widget.data['id'],
                                  quantity: newQuantity.toString());

                              // Close dialog after successful update
                              Navigator.of(context).pop();

                              // Refresh state
                              setState(() {
                                widget.data['quantity'] =
                                    newQuantity.toString();
                              });
                            } catch (e) {
                              // Show error in Snackbar
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error updating quantity: $e'),
                                  duration: Duration(seconds: 3),
                                ),
                              );
                            }
                          },
                          child: Text("Save"),
                        ),
                      ],
                    );
                  },
                );
              } else if (value == 'delete') {
                bool confirmDelete = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Confirm Delete"),
                      content:
                          Text("Are you sure you want to delete this item?"),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(
                              false), // Return false when cancel is pressed
                          child: Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context)
                              .pop(true), // Return true when delete is pressed
                          child: Text("Delete"),
                        ),
                      ],
                    );
                  },
                );

                if (confirmDelete == true) {
                  // Delete the item from PocketBase.
                  try {
                    await ItemService()
                        .deleteItem(widget.data['id']); // Corrected line
                    // Navigate back after successful deletion
                    Navigator.pop(context);
                  } catch (e) {
                    // Show error in Snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error deleting item: $e'),
                        duration:
                            Duration(seconds: 3), // Adjust duration as needed
                      ),
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width - 30,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(3, 3),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: MaterialItemCard(
                  data: widget.data,
                  clickable: false,
                  onSalePressed: () {},
                  showPlusButton: false,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: MediaQuery.of(context).size.width - 20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.data['description'],
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    quantityController.dispose();
    super.dispose();
  }
}
