import 'package:flutter/material.dart';
import 'package:npc/data/repositories/s3_repository.dart';
import 'package:npc/core/api/base_api_service.dart';

class S3ViewModel with ChangeNotifier {
  final S3Repository _s3Repository = S3Repository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<String> _uploadedUrls = [];
  List<String> get uploadedUrls => _uploadedUrls;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // File upload karne ka logic
  Future<List<String>?> uploadFiles({
    required String email,
    required List<String> filePaths,
    String keyName = 'files', // Backend 'files' list expect kr rha ha
    String scope = 'profile', // Default scope added
  }) async {
    _setLoading(true);
    _errorMessage = null;
    _uploadedUrls = [];

    try {
      final urls = await _s3Repository.uploadFiles(
        email: email,
        filePaths: filePaths,
        keyName: keyName,
        scope: scope,
      );

      _uploadedUrls = urls;
      _setLoading(false);
      return urls;
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

  void clearErrors() {
    _errorMessage = null;
    notifyListeners();
  }
}
