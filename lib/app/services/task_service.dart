import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:task_manager/app/models/task_model.dart';

class TaskService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Collection reference helper
  static CollectionReference<Map<String, dynamic>> _userTasksRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('tasks');
  }

  /// Add a New Task to Firestore
  static Future<TaskModel> addTask(TaskModel task) async {
    try {
      final docRef = _userTasksRef(task.userId).doc();
      final newTask = task.copyWith(id: docRef.id);
      await docRef.set(newTask.toMap());
      debugPrint('Task added successfully: ${docRef.id}');
      return newTask;
    } catch (e) {
      debugPrint('Error adding task: $e');
      rethrow;
    }
  }

  /// Stream User Tasks Real-Time
  static Stream<List<TaskModel>> streamUserTasks(String userId) {
    if (userId.isEmpty) {
      return Stream.value([]);
    }

    return _userTasksRef(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TaskModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  /// Toggle Task Completion Status
  static Future<void> toggleTaskStatus(
    String userId,
    String taskId,
    bool isCompleted,
  ) async {
    try {
      await _userTasksRef(userId).doc(taskId).update({
        'isCompleted': isCompleted,
      });
      debugPrint('Task status toggled to $isCompleted for $taskId');
    } catch (e) {
      debugPrint('Error toggling task status: $e');
      rethrow;
    }
  }

  /// Update Existing Task
  static Future<void> updateTask(TaskModel task) async {
    try {
      await _userTasksRef(task.userId).doc(task.id).update(task.toMap());
      debugPrint('Task updated successfully: ${task.id}');
    } catch (e) {
      debugPrint('Error updating task: $e');
      rethrow;
    }
  }

  /// Delete Task from Firestore
  static Future<void> deleteTask(String userId, String taskId) async {
    try {
      await _userTasksRef(userId).doc(taskId).delete();
      debugPrint('Task deleted: $taskId');
    } catch (e) {
      debugPrint('Error deleting task: $e');
      rethrow;
    }
  }
}
