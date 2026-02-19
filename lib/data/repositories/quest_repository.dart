import 'package:npc/core/api/api_constants.dart';
import 'package:npc/core/api/base_api_service.dart';
import 'package:npc/data/models/quest_model.dart';

// Quests se mutaliq saari API calls yahan handle hongi
class QuestRepository {
  final BaseApiService _apiService = BaseApiService();

  // Saare quests mangwane wala function (Filter ke saath)
  Future<QuestListResponse> getAllQuests({String? status}) async {
    try {
      String url = ApiConstants.baseUrl + ApiConstants.allQuestsEndpoint;

      // Agar status filter diya gaya ha to query parameter add kryn
      if (status != null && status.isNotEmpty) {
        url += "?status=$status";
      }

      // Authorized call kyunke quests dekhne ke liye login zaroori ha
      dynamic response = await _apiService.getAuthorizedResponse(url);
      return QuestListResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // User ke apne quests mangwana (Filter ke saath)
  Future<QuestListResponse> getMyQuests({String? status}) async {
    try {
      String url = ApiConstants.baseUrl + ApiConstants.myQuestsEndpoint;

      // Agar status filter diya gaya ha to query parameter add kryn
      if (status != null && status.isNotEmpty) {
        url += "?status=$status";
      }

      dynamic response = await _apiService.getAuthorizedResponse(url);
      return QuestListResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Kisi specific user ke quests mangwana (Team member view)
  Future<QuestListResponse> getQuestsByUserId(
    String userId, {
    String? status,
  }) async {
    try {
      String url =
          "${ApiConstants.baseUrl}${ApiConstants.teamQuestsByUserIdEndpoint}/$userId";

      // Agar status filter diya gaya ha to query parameter add kryn
      if (status != null && status.isNotEmpty) {
        url += "?status=$status";
      }

      dynamic response = await _apiService.getAuthorizedResponse(url);
      return QuestListResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Naya quest banane ka function
  Future<QuestModel> createQuest(Map<String, dynamic> data) async {
    try {
      final url = ApiConstants.baseUrl + ApiConstants.createQuestEndpoint;
      dynamic response = await _apiService.postAuthorizedResponse(url, data);

      // Quest key ke andar quest ka data hota ha response me
      if (response['quest'] != null) {
        return QuestModel.fromJson(response['quest']);
      }
      return QuestModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Aik specific quest ki details mangwana
  Future<QuestModel> getQuestById(String id) async {
    try {
      final url =
          "${ApiConstants.baseUrl}${ApiConstants.createQuestEndpoint}/$id";
      dynamic response = await _apiService.getAuthorizedResponse(url);

      if (response['quest'] != null) {
        return QuestModel.fromJson(response['quest']);
      }
      return QuestModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Quest update karne ka function (PUT)
  Future<QuestModel> updateQuest(String id, Map<String, dynamic> data) async {
    try {
      final url =
          "${ApiConstants.baseUrl}${ApiConstants.createQuestEndpoint}/$id";
      dynamic response = await _apiService.putAuthorizedResponse(url, data);

      if (response['quest'] != null) {
        return QuestModel.fromJson(response['quest']);
      }
      return QuestModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Quest delete karne ka function (DELETE)
  Future<Map<String, dynamic>> deleteQuest(String id) async {
    try {
      final url =
          "${ApiConstants.baseUrl}${ApiConstants.createQuestEndpoint}/$id";
      dynamic response = await _apiService.deleteAuthorizedResponse(url);
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  // Quest ka status update karna (e.g. start, submit)
  Future<Map<String, dynamic>> updateQuestStatus(
    String id,
    String action,
  ) async {
    try {
      final url =
          "${ApiConstants.baseUrl}${ApiConstants.updateQuestStatusEndpoint}/$id/$action";
      dynamic response = await _apiService.postAuthorizedResponse(url, {});
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  // Quest mein team members add karne ka function
  Future<QuestModel> addTeamMembers(
    String questId,
    String userId,
    List<String> userIds,
  ) async {
    try {
      final url = ApiConstants.baseUrl + ApiConstants.addTeamMembersEndpoint;
      final data = {"questId": questId, "userId": userId, "userIds": userIds};

      dynamic response = await _apiService.postAuthorizedResponse(url, data);

      if (response['quest'] != null) {
        return QuestModel.fromJson(response['quest']);
      }
      return QuestModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Quest se team member remove karne ka function
  Future<QuestModel> removeTeamMember(String questId, String userId) async {
    try {
      final url =
          "${ApiConstants.baseUrl}/quests/$questId/team-members/$userId";
      dynamic response = await _apiService.deleteAuthorizedResponse(url);

      if (response['quest'] != null) {
        return QuestModel.fromJson(response['quest']);
      }
      return QuestModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
