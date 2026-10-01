import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventocharm/components/constants/colors.dart';
import 'package:inventocharm/screens/settings/services/export_to_cvs_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;

class ExportToExcelButton extends StatelessWidget {
  const ExportToExcelButton({Key? key}) : super(key: key);

  Future<void> openAppSettings() async {
    const platform = MethodChannel('com.example.app/settings');
    try {
      await platform.invokeMethod('openAppSettings');
    } on PlatformException catch (e) {
      print("Failed to open settings: '${e.message}'.");
    }
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> _localFile(String filename) async {
    final path = await _localPath;
    return File('$path/$filename');
  }

  Future<void> saveFileLocally(String data, String filename) async {
    final file = await _localFile(filename);
    await file.writeAsString(data);
  }

  Future<void> sendTelegramMessage(String filePath) async {
    const botToken = '7059331506:AAHiD928k21-Hql4K1xLDFDmDOtycUCoQHo';
    // CHAT ID
    const chatId = '1570670519'; // CHAT ID
    final url = Uri.parse('https://api.telegram.org/bot$botToken/sendDocument');

    final file = File(filePath);
    final fileName = file.path.split('/').last;

    final request = http.MultipartRequest('POST', url)
      ..fields['chat_id'] = chatId
      ..files.add(await http.MultipartFile.fromPath('document', file.path,
          filename: fileName));

    final response = await request.send();
    if (response.statusCode == 200) {
      print('CSV file sent via Telegram successfully.');
    } else {
      print(
          'Failed to send CSV file via Telegram. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: CustomColors.success,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      onPressed: () async {
        // Request storage permission if needed
        final plugin = DeviceInfoPlugin(); // Instantiate DeviceInfoPlugin
        AndroidDeviceInfo android; // Declare AndroidDeviceInfo variable
        try {
          android = await plugin.androidInfo; // Await androidInfo
        } catch (e) {
          print("Error fetching Android device info: $e");
          return; // Exit onPressed callback if error occurs
        }

        final storageStatus = android.version.sdkInt < 33
            ? await Permission.storage.request()
            : PermissionStatus.granted;

        if (storageStatus == PermissionStatus.granted) {
          String? filePath = await ExportCsvService().exportDataToCsv();
          if (filePath != null) {
            try {
              await sendTelegramMessage(filePath);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content:
                    Text('Sales data CSV file sent via Telegram successfully.'),
              ));
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('Failed to send sales data CSV file via Telegram.'),
                ),
              );
              print('Error sending email: $e');
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to export data.'),
              ),
            );
          }
        } else if (storageStatus == PermissionStatus.denied) {
          // Handle temporary permission denied
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Storage permission is required to export data.'),
              action: SnackBarAction(
                label: 'Open Settings',
                onPressed: () {
                  openAppSettings();
                },
              ),
            ),
          );
        } else if (storageStatus == PermissionStatus.permanentlyDenied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Storage permission is required to export data. Please enable it from settings.'),
            ),
          );
        }
      },
      child: Text('Export Sales to CSV'),
    );
  }
}
