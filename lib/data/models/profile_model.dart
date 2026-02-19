import 'package:flutter/foundation.dart';

// Ye Model class profile ka data handle karne ke liye hai
class ProfileModel {
  String? id;
  String? email;
  String? name;
  String? profilePicture;
  String? role;
  String? subscriptionType;
  bool? isNotifications;
  bool? isVerified;
  bool? isProfileCompleted;
  String? message; // Server se aane wala success/error message

  ProfileModel({
    this.id,
    this.email,
    this.name,
    this.profilePicture,
    this.role,
    this.subscriptionType,
    this.isNotifications,
    this.isVerified,
    this.isProfileCompleted,
    this.message,
  });

  // JSON data ko Dart object mein convert karta hai (API se data lete waqt)
  ProfileModel.fromJson(Map<String, dynamic> json) {
    // Debugging ke liye response print kr rhy hain
    debugPrint("DEBUG: Profile Model Parsing -> $json");

    // Message aksar top level par hota hai
    message = json['message']?.toString();

    // Mapping logic: Hum multiple levels aur multiple keys check kryn gay
    // Taake agar backend structure change bhi ho jaye to app na tootay

    // Hum pehle data ko 'data' key ke andar dhundtay hain (kaafi APIs aisa krti hain)
    Map<String, dynamic> root =
        (json.containsKey('data') && json['data'] is Map<String, dynamic>)
        ? json['data']
        : json;

    // Helper functions for common keys
    String? getString(Map<String, dynamic> map, List<String> possibleKeys) {
      for (var key in possibleKeys) {
        if (map[key] != null) return map[key].toString();
      }
      return null;
    }

    // Possible keys for Name
    final nameKeys = [
      'name',
      'fullName',
      'full_name',
      'username',
      'userName',
      'display_name',
      'displayName',
    ];
    // Possible keys for Picture
    final picKeys = [
      'profilePicture',
      'profile_picture',
      'imageUrl',
      'image_url',
      'image',
      'picture',
    ];

    // 1. Pehle current root level pr check kryn gay
    id =
        root['id']?.toString() ??
        root['_id']?.toString() ??
        root['userId']?.toString() ??
        json['id']?.toString();
    debugPrint("DEBUG: Parsed Profile ID -> $id");
    email = root['email'] ?? json['email'];
    name = getString(root, nameKeys);
    profilePicture = getString(root, picKeys);

    // Extra fields
    role = root['role']?.toString();
    subscriptionType = root['subscriptionType']?.toString();
    isNotifications =
        root['isNotifications'] ??
        root['isNotification'] ??
        root['notifications'];
    isVerified = root['isVerified'];
    isProfileCompleted = root['isProfileCompleted'];

    // 2. Agar nahi mila to ek level mazeed andar ja kr dhoondhty hain (user, profile type wrappers)
    final wrappers = [
      'user',
      'profile',
      'account',
      'data',
      'details',
      'result',
    ];
    for (var wrapper in wrappers) {
      if (name != null && role != null) {
        break; // Agar kafi had tak data mil gaya to mazeed loop chalanay ki zaroorat nhi
      }

      if (root[wrapper] is Map<String, dynamic>) {
        final nested = root[wrapper] as Map<String, dynamic>;
        id ??=
            nested['id']?.toString() ??
            nested['_id']?.toString() ??
            nested['userId']?.toString();
        email ??= nested['email'];
        name ??= getString(nested, nameKeys);
        profilePicture ??= getString(nested, picKeys);

        // Nested extra fields
        role ??= nested['role']?.toString();
        subscriptionType ??= nested['subscriptionType']?.toString();
        isNotifications ??=
            nested['isNotifications'] ??
            nested['isNotification'] ??
            nested['notifications'];
        isVerified ??= nested['isVerified'];
        isProfileCompleted ??= nested['isProfileCompleted'];
      }
    }
  }

  // Dart object ko JSON mein convert karta hai (API ko data bhejte waqt)
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['email'] = email;
    data['name'] = name;
    data['profilePicture'] = profilePicture;
    data['role'] = role;
    data['subscriptionType'] = subscriptionType;
    data['isNotifications'] = isNotifications;
    data['isVerified'] = isVerified;
    data['isProfileCompleted'] = isProfileCompleted;
    data['message'] = message;
    return data;
  }
}
