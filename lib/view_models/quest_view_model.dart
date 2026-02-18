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

  List<QuestModel> _completedQuests = [];
  List<QuestModel> get completedQuests => _completedQuests;

  // Counters for UI
  int get pendingCount => _pendingQuests.length;
  int get completedCount => _completedQuests.length;
  int get totalCount =>
      _pendingQuests.length +
      _inProgressQuests.length +
      _completedQuests.length;

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
  Future<void> fetchMyQuests(String status) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await _questRepo.getMyQuests(status: status);

      if (status == 'pending') {
        _pendingQuests = response.quests ?? [];
      } else if (status == 'in-progress') {
        _inProgressQuests = response.quests ?? [];
      } else if (status == 'submitted' ||
          status == 'completed' ||
          status == 'approved' ||
          status == 'rejected') {
        _completedQuests = response.quests ?? [];
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
      } else if (status == 'submitted' ||
          status == 'completed' ||
          status == 'approved' ||
          status == 'rejected') {
        _completedQuests = response.quests ?? [];
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
      } else if (status == 'submitted' ||
          status == 'completed' ||
          status == 'approved' ||
          status == 'rejected') {
        _completedQuests = response.quests ?? [];
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

  // Quest status update karne ka function (Action logic)
  Future<bool> updateStatus(String questId, String action) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _questRepo.updateQuestStatus(questId, action);
      _successMessage = "Status updated successfully: $action";

      // Data refresh kryn gay taake UI update ho jaye
      // NOTE: Real app mein hum list se item remove ya move bhi kr skty hain locally
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
}
