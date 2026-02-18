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
        } else if (e.statusCode == 500) {
          _errorMessage = "Failed to fetch profile";
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
        } else if (e.statusCode == 500) {
          _errorMessage = "Failed to update profile";
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
}
