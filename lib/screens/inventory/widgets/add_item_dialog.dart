import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:inventocharm/services/pocketbase_client.dart';
import 'package:inventocharm/components/constants/colors.dart';
import 'package:inventocharm/components/my_text_field.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class AddItemDialog extends StatefulWidget {
  @override
  _AddItemDialogState createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _costController = TextEditingController();

  File? _imageFile;
  String? qrCodeResult;
  bool _isUploading = false;

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? qrController;

  Future<void> _getImage() async {
    try {
      if (Platform.isAndroid) {
        var permission = await Permission.storage.request();
        if (!permission.isGranted && !permission.isLimited) {
          permission = await Permission.photos.request();
        }
        if (!permission.isGranted && !permission.isLimited) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Storage permission is required to select an image.'),
            ),
          );
          return;
        }
      } else if (Platform.isIOS) {
        final permission = await Permission.photos.request();
        if (!permission.isGranted && !permission.isLimited) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo permission is required to select an image.'),
            ),
          );
          return;
        }
      }

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not select image: $error')),
      );
    }
  }

  Future<String?> _uploadImage() async {
    try {
      if (_imageFile == null) return null;
      setState(() {
        _isUploading = true;
      });
      if (mounted) setState(() => _isUploading = false);
      return _imageFile!.path;
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      // Display error to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading image: $e'),
          duration: Duration(seconds: 3),
        ),
      );
      return null;
    }
  }

  Future<void> _saveItemData(String imageUrl) async {
    try {
      String itemName = _itemNameController.text;
      String price = _priceController.text;
      String quantity = _quantityController.text;
      String description = _descriptionController.text;
      String cost = _costController.text;

      final image = await http.MultipartFile.fromPath('image', imageUrl);
      await pocketBase.collection('items').create(
        body: {
          'name': itemName,
          'price': price,
          'quantity': quantity,
          'description': description,
          'cost': cost,
          'code': qrCodeResult,
        },
        files: [image],
      );

      // Item saved successfully
      Navigator.pop(context); // Close the dialog
    } catch (error) {
      // Display error to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add item: $error'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: CustomColors.grey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                MyTextField(
                  controller: _itemNameController,
                  hintText: 'Enter Item Name',
                  obscureText: false,
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter item name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 8),
                MyTextField(
                  controller: _priceController,
                  hintText: 'Enter Price',
                  obscureText: false,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 8),
                MyTextField(
                  controller: _quantityController,
                  hintText: 'Enter Quantity',
                  obscureText: false,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter quantity';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 8),
                MyTextField(
                  controller: _descriptionController,
                  hintText: 'Enter Description',
                  obscureText: false,
                  keyboardType: TextInputType.text,
                ),
                SizedBox(height: 8),
                MyTextField(
                  controller: _costController,
                  hintText: 'Enter Cost',
                  obscureText: false,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter cost';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    minimumSize: Size(double.infinity, 0),
                  ),
                  onPressed: () async {
                    await _getImage();
                  },
                  child: Text('Upload Image',
                      style: TextStyle(color: Colors.white)),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColors.secondaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    minimumSize: Size(double.infinity, 0),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          final scanSize =
                              (MediaQuery.sizeOf(context).shortestSide - 48)
                                  .clamp(180.0, 300.0);
                          return Dialog(
                            child: SizedBox(
                              width: scanSize,
                              height: scanSize,
                              child: QRView(
                                key: qrKey,
                                onQRViewCreated: (controller) {
                                  this.qrController = controller;
                                  controller.scannedDataStream.listen(
                                    (scanData) {
                                      setState(() {
                                        qrCodeResult = scanData.code;
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                  child: Text('Scan QR Code',
                      style: TextStyle(color: CustomColors.primaryColor)),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColors.success,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    minimumSize: Size(double.infinity, 0),
                  ),
                  onPressed: () async {
                    String? imageUrl = await _uploadImage();
                    if (imageUrl != null) {
                      await _saveItemData(imageUrl);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to upload image'),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                  child: _isUploading
                      ? CircularProgressIndicator()
                      : Text('Save Item',
                          style: TextStyle(color: CustomColors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
