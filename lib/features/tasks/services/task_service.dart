import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:npc/features/tasks/data/task_model.dart';
import 'package:flutter/foundation.dart';

// Firestore ke saath mil kar Tasks (Quests) ka saara kaam sambhalnay wali service
class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Naya task Firestore mein save karne ka function
  Future<void> createTask(TaskModel task) async {
    try {
      await _firestore.collection('tasks').add(task.toMap());
    } catch (e) {
      debugPrint("Error creating task: $e");
      throw Exception("Failed to create task");
    }
  }

  // Task complete hone par status update karna aur tasveerein save karna
  Future<void> completeTask(String taskId, {List<String>? imagePaths}) async {
    try {
      // Filhaal images ko Base64 format mein direct Firestore mein save kiya ja raha hai
      await _firestore.collection('tasks').doc(taskId).update({
        'status': 'Completed',
        'completedAt': FieldValue.serverTimestamp(),
        'images': imagePaths ?? [],
      });
    } catch (e) {
      debugPrint("Error completing task: $e");
      throw Exception("Failed to complete task");
    }
  }

  // Sirf tasveerein upload karne ka function (Status change nahi hoga)
  Future<void> uploadTaskImages(String taskId, List<String> imagePaths) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'images': imagePaths,
      });
    } catch (e) {
      debugPrint("Error uploading images: $e");
      throw Exception("Failed to upload images");
    }
  }

  // Admin ke liye task ka status (Approve/Reject) update karne ka function
  Future<void> updateTaskStatus(String taskId, String status) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'status': status,
      });
    } catch (e) {
      debugPrint("Error updating task status: $e");
      throw Exception("Failed to update task status");
    }
  }

  // Get stream of tasks for the current user (or all tasks if needed)
  // Assuming we want to show all tasks or tasks relevant to the user
  // Firestore se real-time tasks lane ka stream
  Stream<List<TaskModel>> getTasksStream({
    String? userId,
    bool viewAll = false, // Agar true ho to tamam users ke tasks (Admin view)
  }) {
    return _firestore
        .collection('tasks')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          final tasks = snapshot.docs.map((doc) {
            return TaskModel.fromMap(doc.data(), doc.id);
          }).toList();

          if (viewAll) {
            return tasks; // Admin ko saare dikhao
          }

          // User ID ki bunyad par tasks filter karna
          final effectiveUserId =
              userId ?? FirebaseAuth.instance.currentUser?.uid;

          if (effectiveUserId != null) {
            return tasks.where((task) {
              final isAssignee = task.assigneeIds.contains(effectiveUserId);
              return isAssignee; // Sirf apne assigned tasks dikhao
            }).toList();
          }

          return []; // Agar user na ho to khali list
        });
  }
}
