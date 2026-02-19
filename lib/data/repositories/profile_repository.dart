import 'package:npc/core/api/api_constants.dart';
import 'package:npc/core/api/base_api_service.dart';
import 'package:npc/data/models/profile_model.dart';

// Ye class APIs se direct rabta (communication) karti hai
class ProfileRepository {
  final BaseApiService _apiService = BaseApiService();

  // Nayi profile banane ke liye (POST request)
  Future<ProfileModel> createProfile(Map<String, dynamic> data) async {
    try {
      dynamic response = await _apiService.postAuthorizedResponse(
        ApiConstants.baseUrl + ApiConstants.createProfileEndpoint,
        data,
      );
      return ProfileModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Profile ka data mangwane ke liye (GET request)
  Future<ProfileModel> getProfile() async {
    try {
      dynamic response = await _apiService.getAuthorizedResponse(
        ApiConstants.baseUrl + ApiConstants.getProfileEndpoint,
      );
      return ProfileModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Profile update karne ke liye (PUT request)
  Future<ProfileModel> updateProfile(Map<String, dynamic> data) async {
    try {
      dynamic response = await _apiService.putAuthorizedResponse(
        ApiConstants.baseUrl + ApiConstants.updateProfileEndpoint,
        data,
      );
      return ProfileModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // User profile update karne ke liye (PATCH request - /user/{id})
  Future<ProfileModel> patchUserProfile(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      dynamic response = await _apiService.patchAuthorizedResponse(
        "${ApiConstants.baseUrl}${ApiConstants.updateUserProfileEndpoint}/$id",
        data,
      );
      return ProfileModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // User ke coins mangwane ke liye (GET request - /user/coins)
  Future<Map<String, dynamic>> getUserCoins() async {
    try {
      dynamic response = await _apiService.getAuthorizedResponse(
        ApiConstants.baseUrl + ApiConstants.userCoinsEndpoint,
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  // Profile khatam/delete karne ke liye (DELETE request)
  Future<dynamic> deleteProfile() async {
    try {
      dynamic response = await _apiService.deleteAuthorizedResponse(
        ApiConstants.baseUrl + ApiConstants.deleteProfileEndpoint,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
