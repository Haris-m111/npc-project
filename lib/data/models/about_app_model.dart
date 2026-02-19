class AboutAppModel {
  final AboutAppContent content;

  AboutAppModel({required this.content});

  factory AboutAppModel.fromJson(Map<String, dynamic> json) {
    return AboutAppModel(content: AboutAppContent.fromJson(json['content']));
  }
}

class AboutAppContent {
  final String id;
  final String content;
  final String language;
  final String platform;
  final String createdAt;
  final String updatedAt;

  AboutAppContent({
    required this.id,
    required this.content,
    required this.language,
    required this.platform,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AboutAppContent.fromJson(Map<String, dynamic> json) {
    return AboutAppContent(
      id: json['_id'],
      content: json['content'],
      language: json['language'],
      platform: json['platform'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
