import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:inventocharm/components/app_bar/custom_app_bar.dart';
import 'package:inventocharm/components/constants/colors.dart';
import 'package:inventocharm/components/constants/helpers/helper_functions.dart';
import 'package:inventocharm/components/search_bar/custom_search_bar.dart';
import 'package:inventocharm/components/widgets/primary_header.dart';
import 'package:inventocharm/models/item.dart';
import 'package:inventocharm/screens/inventory/services/inventory_change_notifier.dart';
import 'package:inventocharm/screens/inventory/services/item_service.dart';
import 'package:inventocharm/screens/inventory/widgets/add_item_dialog.dart';
import 'package:inventocharm/screens/inventory/widgets/material_item_card.dart';
import 'package:inventocharm/screens/inventory/widgets/record_sale_dialog.dart';

class Inventory extends StatefulWidget {
  const Inventory({super.key});

  @override
  State<Inventory> createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
  final _service = ItemService();

  List<Item> _items = const [];
  final Set<String> _selectedIds = {};
  String _searchText = '';

  bool _isLoading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final items = await _service.getItems();
      if (!mounted) return;
      setState(() {
        _items = items;
        _isLoading = false;
        // Drop selections that no longer exist.
        _selectedIds.removeWhere(
          (id) => !items.any((item) => item.id == id),
        );
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshAfterChange() async {
    InventoryChangeNotifier.notifyChanged();
    await _refresh();
  }

  Future<void> _openAddItemDialog() async {
    final added = await showDialog<bool>(
      context: context,
      builder: (_) => const AddItemDialog(),
    );
    if (added == true && mounted) await _refreshAfterChange();
  }

  void _toggleSelection(Item item) {
    setState(() {
      if (_selectedIds.contains(item.id)) {
        _selectedIds.remove(item.id);
      } else {
        _selectedIds.add(item.id);
      }
    });
  }

  List<Item> get _visibleItems {
    final query = _searchText.trim().toLowerCase();
    if (query.isEmpty) return _items;

    return _items.where((item) {
      final name = item.name.toLowerCase();
      final code = item.code?.toLowerCase() ?? '';
      return name.contains(query) || code.contains(query);
    }).toList(growable: false);
  }

  List<Item> get _selectedItems =>
      _items.where((i) => _selectedIds.contains(i.id)).toList(growable: false);

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);
    final visible = _visibleItems;
    const gridSpacing = 12.0;
    const maxCardWidth = 260.0;
    final availableGridWidth = MediaQuery.sizeOf(context).width - 32;
    final columnCount =
        ((availableGridWidth + gridSpacing) / (maxCardWidth + gridSpacing))
            .ceil()
            .clamp(1, 100);
    final cardWidth =
        (availableGridWidth - (columnCount - 1) * gridSpacing) / columnCount;
    final imageHeight = ((cardWidth - 16) * 0.56).clamp(84.0, 132.0).toDouble();
    final nameHeight = MaterialItemCard.itemNameLineHeight(context) * 2;

    return Scaffold(
      backgroundColor: dark ? CustomColors.black : CustomColors.lightestGrey,
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            if (_isLoading && _items.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _ErrorState(error: _error!, onRetry: _refresh),
              )
            else if (visible.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyState(
                  isSearching: _searchText.trim().isNotEmpty,
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: maxCardWidth,
                    mainAxisExtent: imageHeight + nameHeight + 96,
                    crossAxisSpacing: gridSpacing,
                    mainAxisSpacing: gridSpacing,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = visible[index];
                      return MaterialItemCard(
                        item: item,
                        onItemChanged: _refreshAfterChange,
                        showPlusButton: !_selectedIds.contains(item.id),
                        onSalePressed: () => _toggleSelection(item),
                      );
                    },
                    childCount: visible.length,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add inventory item',
        backgroundColor: CustomColors.primaryColor,
        onPressed: _openAddItemDialog,
        child: const Icon(Icons.add, color: CustomColors.white),
      ),
    );
  }

  Widget _buildHeader() {
    final selectionCount = _selectedIds.length;

    return CustomPrimaryHeader(
      height: 250,
      child: Column(
        children: [
          CustomAppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to Inventocharm',
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.apply(color: CustomColors.white),
                ),
                Text(
                  'Your Inventory',
                  style: Theme.of(context).textTheme.titleMedium?.apply(
                        color: CustomColors.white,
                        fontWeightDelta: 2,
                      ),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: selectionCount == 0
                    ? 'Select items to record a sale'
                    : 'Record sale ($selectionCount)',
                onPressed: selectionCount == 0 ? null : _openRecordSaleDialog,
                icon: const Icon(FontAwesomeIcons.fileExport),
                color: CustomColors.white,
              ),
            ],
          ),
          const SizedBox(height: 25),
          CustomSearchContainer(
            text: 'Search inventory',
            onTextChanged: (text) => setState(() => _searchText = text),
          ),
        ],
      ),
    );
  }

  Future<void> _openRecordSaleDialog() async {
    await showDialog<void>(
      context: context,
      builder: (_) => RecordSaleDialog(
        selectedItems: _selectedItems,
        onSaleRecorded: (_) {
          if (!mounted) return;
          setState(_selectedIds.clear);
          _refreshAfterChange();
        },
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 42),
            const SizedBox(height: 12),
            Text(
              'Could not load inventory',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(error.toString(), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isSearching});

  final bool isSearching;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        isSearching ? 'No matching items' : 'No inventory items yet',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}
