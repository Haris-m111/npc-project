import 'package:flutter/material.dart';
import 'package:npc/data/models/about_app_model.dart';
import 'package:npc/data/repositories/about_app_repository.dart';

class AboutAppViewModel with ChangeNotifier {
  final AboutAppRepository _repository = AboutAppRepository();

  AboutAppContent? _aboutApp;
  AboutAppContent? get aboutApp => _aboutApp;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchAboutApp({String language = 'en'}) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final model = await _repository.fetchAboutApp(language: language);
      _aboutApp = model.content;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }
}
