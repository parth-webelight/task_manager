import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class CategoryService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const List<String> defaultCategories = [
    'Work',
    'Personal',
    'Shopping',
    'Fitness',
  ];

  /// User categories collection reference helper
  static CollectionReference<Map<String, dynamic>> _userCategoriesRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('categories');
  }

  /// Initialize default categories in Firestore if user's collection is empty
  static Future<void> initializeDefaultCategoriesIfEmpty(String userId) async {
    if (userId.isEmpty) return;

    try {
      final snapshot = await _userCategoriesRef(userId).get();
      if (snapshot.docs.isEmpty) {
        final batch = _firestore.batch();
        for (var cat in defaultCategories) {
          final docRef = _userCategoriesRef(userId).doc(cat.toLowerCase());
          batch.set(docRef, {
            'name': cat,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
        await batch.commit();
        debugPrint('Default categories written to Firestore for $userId');
      }
    } catch (e) {
      debugPrint('Error initializing categories in Firestore: $e');
    }
  }

  /// Stream User Categories Direct From Firestore
  static Stream<List<String>> streamUserCategories(String userId) {
    if (userId.isEmpty) {
      return Stream.value([]);
    }

    return _userCategoriesRef(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => doc.data()['name'] as String? ?? '')
          .where((name) => name.isNotEmpty)
          .toList();
      return list;
    });
  }

  /// Add a New Custom Category in Firestore
  static Future<void> addCustomCategory(String userId, String categoryName) async {
    final cleanName = categoryName.trim();
    if (cleanName.isEmpty || userId.isEmpty) return;

    try {
      final docId = cleanName.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final docRef = _userCategoriesRef(userId).doc(docId);
      await docRef.set({
        'name': cleanName,
        'createdAt': FieldValue.serverTimestamp(),
      });
      debugPrint('Custom category added to Firestore: $cleanName');
    } catch (e) {
      debugPrint('Error adding custom category to Firestore: $e');
      rethrow;
    }
  }

  /// Delete a Category from Firestore
  static Future<void> deleteCategory(String userId, String categoryName) async {
    if (userId.isEmpty || categoryName.isEmpty) return;

    try {
      final docId = categoryName.trim().toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      await _userCategoriesRef(userId).doc(docId).delete();
      debugPrint('Category deleted from Firestore: $categoryName');
    } catch (e) {
      debugPrint('Error deleting category from Firestore: $e');
      rethrow;
    }
  }
}
