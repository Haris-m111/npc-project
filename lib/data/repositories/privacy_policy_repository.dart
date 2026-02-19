import 'package:npc/core/api/api_constants.dart';
import 'package:npc/core/api/base_api_service.dart';
import 'package:npc/data/models/privacy_policy_model.dart';

class PrivacyPolicyRepository {
  final BaseApiService _apiService = BaseApiService();

  Future<PrivacyPolicyModel> fetchPrivacyPolicy() async {
    try {
      final url = ApiConstants.baseUrl + ApiConstants.privacyPolicyEndpoint;
      final response = await _apiService.getResponse(url);
      return PrivacyPolicyModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
