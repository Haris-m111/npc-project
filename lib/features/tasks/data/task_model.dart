import 'package:cloud_firestore/cloud_firestore.dart';

// App mein kisi bhi Task (Quest) ka data structure define karne wali class
class TaskModel {
  final String id; // Task ki unique ID
  final String title; // Task ka unwan
  final String description; // Task ki tafseel
  final DateTime deadline; // Task khatam karne ki aakhri tareekh
  final List<String>
  assigneeIds; // Un users ki IDs jinhein task assign kiya gaya hai
  final String creatorId; // Task banane wale admin ki ID
  final String
  status; // Task ki mojooda halat (e.g., Pending, Completed, Approved)
  final DateTime createdAt; // Task kab banaya gaya
  final List<String> images; // Task submit karte waqt upload ki gayi tasveerein

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    required this.assigneeIds,
    required this.creatorId,
    this.status = 'Pending',
    required this.createdAt,
    this.images = const [],
  });

  // Firestore data (Map) ko TaskModel object mein tabdeel karne wala function
  factory TaskModel.fromMap(Map<String, dynamic> data, String id) {
    // Purane data (single assignee) ko naye list format mein convert karna
    List<String> assignees = [];

    if (data['assigneeIds'] != null) {
      assignees = List<String>.from(data['assigneeIds']);
    } else if (data['assigneeId'] != null) {
      assignees = [data['assigneeId']];
    }

    return TaskModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      deadline: data['deadline'] is Timestamp
          ? (data['deadline'] as Timestamp).toDate()
          : DateTime.now(),
      assigneeIds: assignees,
      creatorId: data['creatorId'] ?? '',
      status: data['status'] ?? 'Pending',
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      images: List<String>.from(data['images'] ?? []),
    );
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? deadline,
    List<String>? assigneeIds,
    String? creatorId,
    String? status,
    DateTime? createdAt,
    List<String>? images,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      assigneeIds: assigneeIds ?? this.assigneeIds,
      creatorId: creatorId ?? this.creatorId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      images: images ?? this.images,
    );
  }

  // TaskModel object ko Firestore mein save karne ke liye Map mein tabdeel karna
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'deadline': Timestamp.fromDate(deadline),
      'assigneeIds': assigneeIds,
      'creatorId': creatorId,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'images': images,
    };
  }
}
