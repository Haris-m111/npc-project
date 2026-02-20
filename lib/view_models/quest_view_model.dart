import 'package:flutter/material.dart';
import 'package:npc/data/models/quest_model.dart';
import 'package:npc/data/repositories/quest_repository.dart';
import 'package:npc/core/api/base_api_service.dart';

class QuestViewModel with ChangeNotifier {
  final QuestRepository _questRepo = QuestRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  // Quest Lists for different tabs
  List<QuestModel> _pendingQuests = [];
  List<QuestModel> get pendingQuests => _pendingQuests;

  List<QuestModel> _inProgressQuests = [];
  List<QuestModel> get inProgressQuests => _inProgressQuests;

  List<QuestModel> _submittedQuests = [];
  List<QuestModel> get submittedQuests => _submittedQuests;

  List<QuestModel> _approvedQuests = [];
  List<QuestModel> get approvedQuests => _approvedQuests;

  List<QuestModel> _rejectedQuests = [];
  List<QuestModel> get rejectedQuests => _rejectedQuests;

  // UI Tab ke liye combined list (Sirf Approved aur Rejected dikhayenge)
  List<QuestModel> get completedQuests => [
    ..._approvedQuests,
    ..._rejectedQuests,
  ];

  // Counters for UI (Submitted ko Completed mein nahi ginain gay)
  int get pendingCount => _pendingQuests.length;
  int get completedCount => _approvedQuests.length + _rejectedQuests.length;
  int get totalCount =>
      _pendingQuests.length +
      _inProgressQuests.length +
      _submittedQuests.length +
      _approvedQuests.length +
      _rejectedQuests.length;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Naya quest banane ka logic
  Future<QuestModel?> createQuest(QuestModel quest) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await _questRepo.createQuest(quest.toJson());
      _successMessage = "Quest created successfully";

      _setLoading(false);
      return response;
    } catch (e) {
      if (e is ApiException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = e.toString();
      }
      _setLoading(false);
      return null;
    }
  }

  // Quest delete karne ka logic
  Future<bool> deleteQuest(String questId) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _questRepo.deleteQuest(questId);
      _successMessage = "Quest deleted successfully";

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

  // Quest update karne ka logic
  Future<bool> updateQuest(String questId, QuestModel quest) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _questRepo.updateQuest(questId, quest.toJson());
      _successMessage = "Quest updated successfully";

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

  // Aik specific quest ki details fetch karne ka function
  Future<QuestModel?> fetchQuestDetails(String questId) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await _questRepo.getQuestById(questId);
      _setLoading(false);
      return response;
    } catch (e) {
      if (e is ApiException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = e.toString();
      }
      _setLoading(false);
      return null;
    }
  }

  // User ke apne quests fetch karne ka function
  Future<void> fetchMyQuests(String status, {bool showLoading = true}) async {
    if (showLoading) _setLoading(true);
    _errorMessage = null;

    try {
      final response = await _questRepo.getMyQuests(status: status);

      if (status == 'pending') {
        _pendingQuests = response.quests ?? [];
      } else if (status == 'in-progress') {
        _inProgressQuests = response.quests ?? [];
      } else if (status == 'submitted') {
        _submittedQuests = response.quests ?? [];
      } else if (status == 'approved') {
        _approvedQuests = response.quests ?? [];
      } else if (status == 'rejected') {
        _rejectedQuests = response.quests ?? [];
      }

      if (showLoading) _setLoading(false);
    } catch (e) {
      if (e is ApiException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = e.toString();
      }
      if (showLoading) _setLoading(false);
    }
  }

  // Quests fetch karne ka main function (Global Quests)
  Future<void> fetchQuests(String status) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await _questRepo.getAllQuests(status: status);

      if (status == 'pending') {
        _pendingQuests = response.quests ?? [];
      } else if (status == 'in-progress') {
        _inProgressQuests = response.quests ?? [];
      } else if (status == 'submitted') {
        _submittedQuests = response.quests ?? [];
      } else if (status == 'approved') {
        _approvedQuests = response.quests ?? [];
      } else if (status == 'rejected') {
        _rejectedQuests = response.quests ?? [];
      }

      _setLoading(false);
    } catch (e) {
      if (e is ApiException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = e.toString();
      }
      _setLoading(false);
    }
  }

  // Team members ke quests fetch karne ka function (By User ID)
  Future<void> fetchTeamQuests(String userId, String status) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await _questRepo.getQuestsByUserId(
        userId,
        status: status,
      );

      if (status == 'pending') {
        _pendingQuests = response.quests ?? [];
      } else if (status == 'in-progress') {
        _inProgressQuests = response.quests ?? [];
      } else if (status == 'submitted') {
        _submittedQuests = response.quests ?? [];
      } else if (status == 'approved') {
        _approvedQuests = response.quests ?? [];
      } else if (status == 'rejected') {
        _rejectedQuests = response.quests ?? [];
      }

      _setLoading(false);
    } catch (e) {
      if (e is ApiException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = e.toString();
      }
      _setLoading(false);
    }
  }

  // Quest status update karne ka function
  Future<bool> updateStatus(String questId, String action) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _questRepo.updateQuestStatus(questId, action);
      _successMessage = "Status updated successfully: $action";

      // Refresh relevant lists only
      if (action == 'start') {
        await fetchMyQuests('pending', showLoading: false);
        await fetchMyQuests('in-progress', showLoading: false);
      } else if (action == 'complete' || action == 'submit') {
        await fetchMyQuests('in-progress', showLoading: false);
        await fetchMyQuests('submitted', showLoading: false);
      } else {
        await fetchAllMyQuests();
      }

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

  // Quest mein team members add karne ka logic
  Future<bool> addTeamMembers(
    String questId,
    String userId,
    List<String> userIds,
  ) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _questRepo.addTeamMembers(questId, userId, userIds);
      _successMessage = "Team members added successfully";
      await fetchQuestDetails(questId);
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

  // Quest se team member remove karne ka logic
  Future<bool> removeTeamMember(String questId, String userId) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _questRepo.removeTeamMember(questId, userId);
      _successMessage = "Team member removed successfully";
      await fetchQuestDetails(questId);
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

  // Parallel mein saray types ke Quests mangwana
  Future<void> fetchAllMyQuests() async {
    _setLoading(true);
    try {
      await Future.wait([
        fetchMyQuests('pending', showLoading: false),
        fetchMyQuests('in-progress', showLoading: false),
        fetchMyQuests('submitted', showLoading: false),
        fetchMyQuests('approved', showLoading: false),
        fetchMyQuests('rejected', showLoading: false),
      ]);
    } catch (e) {
      debugPrint("Error fetching all my quests: $e");
    } finally {
      _setLoading(false);
    }
  }
}
