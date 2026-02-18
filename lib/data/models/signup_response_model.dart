class SignUpResponseModel {
  String? message;
  String? accessToken;
  String? refreshToken;
  Map<String, dynamic>? user;

  SignUpResponseModel({
    this.message,
    this.accessToken,
    this.refreshToken,
    this.user,
  });

  // JSON sy object banane wala function (Deserialization)
  SignUpResponseModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    accessToken = json['accessToken'];
    refreshToken = json['refreshToken'];
    user = json['user'];
  }

  // Object sy wapis JSON banane wala function (Serialization)
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['accessToken'] = accessToken;
    data['refreshToken'] = refreshToken;
    data['user'] = user;
    return data;
  }
}
