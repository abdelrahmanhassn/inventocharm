import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:inventocharm/components/constants/colors.dart';
import 'package:inventocharm/components/my_text_field.dart';
import 'package:inventocharm/models/item.dart';
import 'package:inventocharm/screens/inventory/services/item_service.dart';
import 'package:inventocharm/services/supabase_client.dart';

class AddItemDialog extends StatefulWidget {
  const AddItemDialog({super.key});

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  static const _bucket = 'item-images';

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _costController = TextEditingController();

  final _service = ItemService();
  final _picker = ImagePicker();

  File? _imageFile;
  String? _scannedCode;
  bool _isUploading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      if (Platform.isAndroid) {
        final permission = await Permission.photos.request();
        if (!permission.isGranted && !permission.isLimited) {
          _showMessage('Photo permission is required to select an image.');
          return;
        }
      } else if (Platform.isIOS) {
        final permission = await Permission.photos.request();
        if (!permission.isGranted && !permission.isLimited) {
          _showMessage('Photo permission is required to select an image.');
          return;
        }
      }

      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;

      setState(() => _imageFile = File(picked.path));
    } catch (e) {
      _showMessage('Could not select image: $e');
    }
  }

  Future<void> _scanCode() async {
    final controller = MobileScannerController();
    final scanned = await showDialog<String?>(
      context: context,
      builder: (context) {
        final scanSize =
            (MediaQuery.sizeOf(context).shortestSide - 48).clamp(180.0, 300.0);
        return Dialog(
          child: SizedBox(
            width: scanSize,
            height: scanSize,
            child: MobileScanner(
              controller: controller,
              onDetect: (capture) {
                final value = capture.barcodes.firstOrNull?.rawValue;
                if (value == null || value.isEmpty) return;
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop(value);
                }
              },
            ),
          ),
        );
      },
    );
    await controller.dispose();

    if (scanned != null) {
      setState(() => _scannedCode = scanned);
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final imageFile = _imageFile;
    if (imageFile == null) {
      _showMessage('Choose an image before saving.');
      return;
    }

    setState(() => _isUploading = true);

    String? storagePath;
    try {
      final ownerId = supabase.auth.currentUser?.id;
      if (ownerId == null) throw StateError('Sign in before adding an item.');

      final filename = imageFile.uri.pathSegments.last;
      storagePath =
          '$ownerId/${DateTime.now().microsecondsSinceEpoch}_$filename';

      await supabase.storage.from(_bucket).upload(storagePath, imageFile);
      final imageUrl = supabase.storage.from(_bucket).getPublicUrl(storagePath);

      final item = Item(
        id: '', // Supabase will assign this
        ownerId: ownerId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        image: imageUrl,
        price: double.parse(_priceController.text),
        cost: double.parse(_costController.text),
        quantity: int.parse(_quantityController.text),
        code: _scannedCode,
      );

      await _service.addItem(item);

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (storagePath != null) {
        try {
          await supabase.storage.from(_bucket).remove([storagePath]);
        } catch (_) {
          // Best-effort cleanup.
        }
      }
      _showMessage('Could not add item: $e');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: CustomColors.grey,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                MyTextField(
                  controller: _nameController,
                  hintText: 'Enter Item Name',
                  obscureText: false,
                  keyboardType: TextInputType.name,
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Please enter item name'
                      : null,
                ),
                const SizedBox(height: 8),
                MyTextField(
                  controller: _priceController,
                  hintText: 'Enter Price',
                  obscureText: false,
                  keyboardType: TextInputType.number,
                  validator: _validateNonNegativeDouble,
                ),
                const SizedBox(height: 8),
                MyTextField(
                  controller: _quantityController,
                  hintText: 'Enter Quantity',
                  obscureText: false,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    return (n == null || n < 0)
                        ? 'Please enter a valid number'
                        : null;
                  },
                ),
                const SizedBox(height: 8),
                MyTextField(
                  controller: _descriptionController,
                  hintText: 'Enter Description',
                  obscureText: false,
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 8),
                MyTextField(
                  controller: _costController,
                  hintText: 'Enter Cost',
                  obscureText: false,
                  keyboardType: TextInputType.number,
                  validator: _validateNonNegativeDouble,
                ),
                const SizedBox(height: 16),
                _actionButton(
                  color: CustomColors.primaryColor,
                  onPressed: _pickImage,
                  child: Text(
                    _imageFile == null ? 'Choose Image' : 'Image Selected',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                _actionButton(
                  color: CustomColors.secondaryColor,
                  onPressed: _scanCode,
                  child: Text(
                    _scannedCode == null
                        ? 'Scan Barcode'
                        : 'Code: $_scannedCode',
                    style: const TextStyle(color: CustomColors.primaryColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 16),
                _actionButton(
                  color: CustomColors.success,
                  onPressed: _isUploading ? null : _save,
                  child: _isUploading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Save Item',
                          style: TextStyle(color: CustomColors.white),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _validateNonNegativeDouble(String? value) {
    final n = double.tryParse(value ?? '');
    return (n == null || n < 0) ? 'Please enter a valid number' : null;
  }

  Widget _actionButton({
    required Color color,
    required VoidCallback? onPressed,
    required Widget child,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        minimumSize: const Size(double.infinity, 0),
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}
