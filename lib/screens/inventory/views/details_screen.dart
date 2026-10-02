import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inventocharm/components/constants/colors.dart';
import 'package:inventocharm/models/item.dart';
import 'package:inventocharm/screens/inventory/services/item_service.dart';

class DetailsScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final Future<void> Function()? onItemChanged;

  const DetailsScreen({
    Key? key,
    required this.data,
    this.onItemChanged,
  }) : super(key: key);

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = int.tryParse(widget.data['quantity']?.toString() ?? '') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = widget.data['name']?.toString() ?? 'Item details';
    final imageUrl = widget.data['image']?.toString() ?? '';

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Item details'),
        backgroundColor: theme.colorScheme.surface,
        actions: [
          IconButton(
            tooltip: 'Delete item',
            onPressed: _deleteItem,
            icon: const Icon(Icons.delete_outline),
            color: CustomColors.error,
          ),
          PopupMenuButton<String>(
            tooltip: 'Item actions',
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'editQuantity',
                child: Row(
                  children: [
                    Icon(FontAwesomeIcons.edit),
                    SizedBox(width: 10),
                    Text('Edit quantity'),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              if (value == 'editQuantity') {
                await _editQuantity();
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wideLayout = constraints.maxWidth >= 760;
            final image = _itemImage(imageUrl);
            final information = _itemInformation(name);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: wideLayout
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 5, child: image),
                            const SizedBox(width: 28),
                            Expanded(flex: 6, child: information),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            image,
                            const SizedBox(height: 24),
                            information,
                          ],
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _itemImage(String imageUrl) {
    return AspectRatio(
      aspectRatio: 1.2,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: imageUrl.isEmpty
            ? const Center(child: Icon(Icons.inventory_2_outlined, size: 64))
            : Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, progress) => progress == null
                    ? child
                    : const Center(child: CircularProgressIndicator()),
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(Icons.broken_image_outlined, size: 64),
                ),
              ),
      ),
    );
  }

  Widget _itemInformation(String name) {
    final theme = Theme.of(context);
    final price = widget.data['price']?.toString() ?? '0';
    final cost = widget.data['cost']?.toString() ?? '0';
    final code = widget.data['code']?.toString();
    final description = widget.data['description']?.toString().trim() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name, style: theme.textTheme.headlineSmall, softWrap: true),
        const SizedBox(height: 8),
        Text(
          '\$$price',
          style: theme.textTheme.titleLarge?.copyWith(
            color: CustomColors.primaryColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 20),
        _detailRow('Available quantity', '$_quantity'),
        _detailRow('Cost per item', '\$$cost'),
        if (code != null && code.isNotEmpty) _detailRow('Barcode', code),
        const SizedBox(height: 20),
        Text('Description', style: theme.textTheme.titleMedium),
        const SizedBox(height: 6),
        Text(
          description.isEmpty ? 'No description provided.' : description,
          style: theme.textTheme.bodyLarge,
          softWrap: true,
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              softWrap: true,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editQuantity() async {
    final quantity = await showDialog<int>(
      context: context,
      builder: (_) => _QuantityEditDialog(initialQuantity: _quantity),
    );
    if (quantity == null || !mounted) return;

    try {
      await ItemService().updateItem(
        Item.fromJson({...widget.data, 'quantity': quantity}),
      );
      if (!mounted) return;
      setState(() => _quantity = quantity);
      await widget.onItemChanged?.call();
    } catch (error) {
      _showMessage('Could not update quantity: $error');
    }
  }

  Future<void> _deleteItem() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete item?'),
        content: Text(
          'Delete ${widget.data['name']?.toString() ?? 'this item'}? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await ItemService().deleteItem(widget.data['id'].toString());
      await widget.onItemChanged?.call();
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      _showMessage('Could not delete item: $error');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _QuantityEditDialog extends StatefulWidget {
  const _QuantityEditDialog({required this.initialQuantity});

  final int initialQuantity;

  @override
  State<_QuantityEditDialog> createState() => _QuantityEditDialogState();
}

class _QuantityEditDialogState extends State<_QuantityEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.initialQuantity}');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit quantity'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Quantity'),
          validator: (value) {
            final parsed = int.tryParse(value ?? '');
            if (parsed == null || parsed < 0) return 'Enter 0 or more';
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              Navigator.pop(context, int.parse(_controller.text));
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
