import 'package:inventocharm/services/pocketbase_client.dart';

class SettingsService {
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final record = await pocketBase.collection('users').getOne(userId);
      return {'id': record.id, ...record.data};
    } catch (e) {
      print("Error getting user data: $e");
      return null;
    }
  }
}

class UserData {
  final String displayName;
  final String email;
  // Add other user data fields here (optional)

  UserData({required this.displayName, required this.email});

  factory UserData.fromMap(Map<String, dynamic> data) => UserData(
        displayName: data['displayName'] ?? '',
        email: data['email'] ?? '',
      );
}
