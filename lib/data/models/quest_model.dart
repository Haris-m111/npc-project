// Quest ka data handle karne ke liye Model class
class QuestModel {
  String? id;
  String? title;
  String? description;
  String? status;
  int? coins;
  String? category;
  DateTime? dueDate;
  DateTime? createdAt;
  List<String>? tags;
  List<String>? images;
  List<String>? teamMembers;

  QuestModel({
    this.id,
    this.title,
    this.description,
    this.status,
    this.coins,
    this.category,
    this.dueDate,
    this.createdAt,
    this.tags,
    this.images,
    this.teamMembers,
  });

  // JSON se Dart object mein convert karne wala function
  QuestModel.fromJson(Map<String, dynamic> json) {
    id = json['_id']?.toString() ?? json['id']?.toString();
    title = json['title']?.toString();
    description = json['description']?.toString();
    status = json['status']?.toString();

    // Coins agar hon to (Standard name 'coins' ya 'reward')
    if (json['coins'] != null) {
      coins = int.tryParse(json['coins'].toString());
    }

    category = json['category']?.toString();

    if (json['dueDate'] != null) {
      dueDate = DateTime.tryParse(json['dueDate'].toString());
    }
    if (json['createdAt'] != null) {
      createdAt = DateTime.tryParse(json['createdAt'].toString());
    }

    if (json['tags'] is List) {
      tags = List<String>.from(json['tags']);
    }
    if (json['images'] is List) {
      images = List<String>.from(json['images']);
    }
    if (json['teamMembers'] is List) {
      teamMembers = List<String>.from(json['teamMembers']);
    }
  }

  // Object ko wapis JSON mein badalne ke liye
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'status': status,
      'coins': coins,
      'category': category,
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'tags': tags,
      'images': images,
      'teamMembers': teamMembers,
    };
  }
}

// Quest list handle karne ke liye helper class
class QuestListResponse {
  String? message;
  List<QuestModel>? quests;

  QuestListResponse({this.message, this.quests});

  QuestListResponse.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      message = json['message'];

      // Quests ki list dhoondh rhy hain data, quests, ya result key me
      var list = json['data'] ?? json['quests'] ?? json['result'];
      if (list is List) {
        quests = list
            .map((v) => QuestModel.fromJson(v as Map<String, dynamic>))
            .toList();
      }
    } else if (json is List) {
      quests = json
          .map((v) => QuestModel.fromJson(v as Map<String, dynamic>))
          .toList();
    }
  }
}
