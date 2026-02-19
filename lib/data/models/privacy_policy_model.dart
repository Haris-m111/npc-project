class PrivacyPolicyModel {
  final int status;
  final bool success;
  final String message;
  final PrivacyPolicyData data;

  PrivacyPolicyModel({
    required this.status,
    required this.success,
    required this.message,
    required this.data,
  });

  factory PrivacyPolicyModel.fromJson(Map<String, dynamic> json) {
    return PrivacyPolicyModel(
      status: json['status'],
      success: json['success'],
      message: json['message'],
      data: PrivacyPolicyData.fromJson(json['data']),
    );
  }
}

class PrivacyPolicyData {
  final PrivacyPolicyDetail privacyPolicy;

  PrivacyPolicyData({required this.privacyPolicy});

  factory PrivacyPolicyData.fromJson(Map<String, dynamic> json) {
    return PrivacyPolicyData(
      privacyPolicy: PrivacyPolicyDetail.fromJson(json['privacyPolicy']),
    );
  }
}

class PrivacyPolicyDetail {
  final String id;
  final String content;
  final String createdAt;
  final String updatedAt;

  PrivacyPolicyDetail({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PrivacyPolicyDetail.fromJson(Map<String, dynamic> json) {
    return PrivacyPolicyDetail(
      id: json['_id'],
      content: json['content'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
