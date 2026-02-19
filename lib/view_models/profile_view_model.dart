import 'package:flutter/material.dart';
import 'package:npc/data/models/profile_model.dart';
import 'package:npc/data/repositories/profile_repository.dart';
import 'package:npc/core/api/base_api_service.dart';

// Ye class UI aur Data ke darmiyan bridge ka kaam karti hai
class ProfileViewModel with ChangeNotifier {
  final ProfileRepository _profileRepository = ProfileRepository();

  // Loading state handle karne ke liye
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Ghalati/Error message dikhane ke liye
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Kamyabi/Success message dikhane ke liye
  String? _successMessage;
  String? get successMessage => _successMessage;

  // User ka data store karne ke liye
  ProfileModel? _userProfile;
  ProfileModel? get userProfile => _userProfile;

  String? _fallbackUserId; // Account ID (Login response se milti hai)
  String? get userId {
    // Priority: Login session se mili hui ID (yaad rakhi hui) > Profile se mili hui ID
    final id = _fallbackUserId ?? _userProfile?.id;
    debugPrint("DEBUG: ProfileViewModel.userId getter -> $id");
    return id;
  }

  // Manual ID set karne ke liye (Naye user ke liye ya Auth se sync krne k liye)
  void setUserId(String? id) {
    if (id != null && id != _fallbackUserId) {
      debugPrint("DEBUG: Setting ProfileViewModel fallbackUserId -> $id");
      _fallbackUserId = id;
      notifyListeners();
    }
  }

  // AuthViewModel se ID sync karne ke liye (ProxyProvider ke liye useful hai)
  void syncUserId(String? id) {
    if (id != null && _fallbackUserId != id) {
      _fallbackUserId = id;
      // notifyListeners mat karain yahan agar build ke darmiyan call ho raha ho
    }
  }

  // Loading state ko set karne wala function
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners(); // UI ko update karne ke liye
  }

  Future<bool> getProfile() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _userProfile = await _profileRepository.getProfile();
      _successMessage = "User profile returned successfully";
      _setLoading(false);
      return true;
    } catch (e) {
      if (e is ApiException) {
        if (e.statusCode == 404) {
          _errorMessage = "Profile not found";
        } else {
          _errorMessage = e.message;
        }
      } else {
        _errorMessage = e.toString();
      }
      _setLoading(false);
      return false;
    }
  }

  // Nayi profile banane ka function
  Future<bool> createProfile(String name, String? profilePicture) async {
    _setLoading(true);
    _errorMessage = null;

    final Map<String, dynamic> data = {
      "name": name,
      "profilePicture": (profilePicture != null && profilePicture.isNotEmpty)
          ? profilePicture
          : null,
    };

    debugPrint("DEBUG: ProfileViewModel.createProfile sending data -> $data");
    try {
      final response = await _profileRepository.createProfile(data);
      _userProfile = response; // Naya data yahan store kr rhy hain
      _successMessage = "Profile created successfully";
      _setLoading(false);
      return true;
    } catch (e) {
      if (e is ApiException && e.statusCode == 500) {
        _errorMessage = "Failed to create profile";
      } else {
        _errorMessage = e.toString();
      }
      _setLoading(false);
      return false;
    }
  }

  // Bani hui profile update karne ka function
  Future<bool> updateProfile(String name, String? profilePicture) async {
    _setLoading(true);
    _errorMessage = null;

    final Map<String, dynamic> data = {
      "name": name,
      "profilePicture": (profilePicture != null && profilePicture.isNotEmpty)
          ? profilePicture
          : null,
    };

    debugPrint("DEBUG: ProfileViewModel.updateProfile sending data -> $data");
    try {
      final response = await _profileRepository.updateProfile(data);
      _userProfile = response; // Updated data yahan store kr rhy hain
      _successMessage = "Profile updated successfully";
      _setLoading(false);
      return true;
    } catch (e) {
      if (e is ApiException) {
        if (e.statusCode == 404) {
          _errorMessage = "Profile not found";
        } else {
          _errorMessage = e.message;
        }
      } else {
        _errorMessage = e.toString();
      }
      _setLoading(false);
      return false;
    }
  }

  // User ke coins store karne ke liye
  int? _coins;
  int? get coins => _coins;

  // Profile/Account delete karne ka function
  Future<bool> deleteProfile() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _profileRepository.deleteProfile();
      _successMessage = "Profile deleted successfully";
      _setLoading(false);
      return true;
    } catch (e) {
      if (e is ApiException && e.statusCode == 500) {
        _errorMessage = "Failed to delete profile";
      } else {
        _errorMessage = e.toString();
      }
      _setLoading(false);
      return false;
    }
  }

  // User profile update karne ka function (PATCH /user/{id})
  Future<bool> patchUserProfile(Map<String, dynamic> data) async {
    final currentId = userId;
    if (currentId == null) {
      _errorMessage = "User ID not found";
      return false;
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await _profileRepository.patchUserProfile(
        currentId,
        data,
      );
      _userProfile = response;
      _successMessage = response.message ?? "Profile updated successfully";
      _setLoading(false);
      return true;
    } catch (e) {
      if (e is ApiException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = e.toString();
      }
      _setLoading(false);
      return false;
    }
  }

  // User ke coins fetch karne ka function
  Future<bool> fetchUserCoins() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await _profileRepository.getUserCoins();
      // Expecting response like {"coins": 100} or data: {"coins": 100}
      final data = (response.containsKey('data') && response['data'] is Map)
          ? response['data']
          : response;
      _coins = int.tryParse(data['coins']?.toString() ?? '0');
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }
}
