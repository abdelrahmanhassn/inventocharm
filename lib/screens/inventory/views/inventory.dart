import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inventocharm/services/supabase_client.dart';
import 'package:inventocharm/components/app_bar/custom_app_bar.dart';
import 'package:inventocharm/components/constants/colors.dart';
import 'package:inventocharm/components/constants/helpers/helper_functions.dart';
import 'package:inventocharm/components/search_bar/custom_search_bar.dart';
import 'package:inventocharm/components/widgets/primary_header.dart';
import 'package:inventocharm/screens/inventory/widgets/add_item_dialog.dart';
import 'package:inventocharm/screens/inventory/widgets/material_item_card.dart';
import 'package:inventocharm/screens/inventory/widgets/record_sale_dialog.dart';

class Inventory extends StatefulWidget {
  const Inventory({Key? key}) : super(key: key);

  @override
  _InventoryState createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
  late TextEditingController _searchController;
  List<Map<String, dynamic>> selectedItems = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  Future<void> _refreshItems() async {
    try {
      await supabase.from('items').select('id').limit(1);
      setState(() {});
    } catch (e) {
      print('Error refreshing items: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = HelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? CustomColors.black : CustomColors.lightestGrey,
      body: RefreshIndicator(
        onRefresh: _refreshItems,
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomPrimaryHeader(
                height: 250,
                child: Column(
                  children: [
                    CustomAppBar(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome to Inventocharm',
                            style:
                                Theme.of(context).textTheme.labelMedium!.apply(
                                      color: CustomColors.white,
                                    ),
                          ),
                          Text(
                            'Your Inventory',
                            style:
                                Theme.of(context).textTheme.titleMedium!.apply(
                                      color: CustomColors.white,
                                      fontWeightDelta: 2,
                                    ),
                          ),
                        ],
                      ),
                      actions: [
                        IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return RecordSaleDialog(
                                  selectedItems: selectedItems,
                                  onSaleRecorded: (p0) {},
                                );
                              },
                            );
                          },
                          icon: const Icon(FontAwesomeIcons.fileExport),
                          color: CustomColors.white,
                        )
                      ],
                    ),
                    const SizedBox(height: 25),
                    CustomSearchContainer(
                      text: "Search Inventory...",
                      onTextChanged: _onSearchTextChanged,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, bottom: 16.0),
                child: SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.6,
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: supabase.from('items').select(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                              'Error loading inventory: ${snapshot.error}'),
                        );
                      }

                      final searchText = _searchController.text.trim();
                      final items = (snapshot.data ?? <Map<String, dynamic>>[])
                          .where((item) {
                        final name =
                            item['name']?.toString().toLowerCase() ?? '';
                        return searchText.isEmpty || name.contains(searchText);
                      }).toList();

                      if (items.isEmpty) {
                        return const Center(child: Text('No items found'));
                      }

                      return GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 9 / 16,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final data = items[index];
                          final docId = data['id'].toString();
                          return MaterialItemCard(
                            showPlusButton: !selectedItems.contains(data),
                            data: data,
                            onSalePressed: () {
                              _addToSelectedItems(data, docId);
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.small(
        backgroundColor: CustomColors.primaryColor,
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AddItemDialog();
            },
          );
        },
        child: const Icon(FontAwesomeIcons.plus, color: CustomColors.white),
      ),
    );
  }

  void _addToSelectedItems(Map<String, dynamic> item, String docId) {
    item['docId'] = docId;
    setState(() {
      item['isSelected'] = true;
    });

    selectedItems.add(item);
  }

  void _onSearchTextChanged(String text) {
    setState(() {
      _searchController.text = text.toLowerCase();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
