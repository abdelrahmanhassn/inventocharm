import 'package:inventocharm/services/supabase_client.dart';

class SettingsService {
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final record = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      return record == null
          ? null
          : {'id': record['id'], 'displayName': record['name'], ...record};
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
