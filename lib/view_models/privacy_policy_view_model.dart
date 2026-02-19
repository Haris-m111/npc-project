import 'package:flutter/material.dart';
import 'package:npc/data/models/privacy_policy_model.dart';
import 'package:npc/data/repositories/privacy_policy_repository.dart';

class PrivacyPolicyViewModel with ChangeNotifier {
  final PrivacyPolicyRepository _repository = PrivacyPolicyRepository();

  PrivacyPolicyDetail? _policy;
  PrivacyPolicyDetail? get policy => _policy;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchPrivacyPolicy() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final model = await _repository.fetchPrivacyPolicy();
      _policy = model.data.privacyPolicy;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }
}
