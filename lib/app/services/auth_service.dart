import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_manager/app/core/utils/session_manager.dart';
import 'package:task_manager/main.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get Current Firebase User
  static User? get currentUser => _auth.currentUser;

  /// Check if user is signed in with Firebase
  static bool get isUserLoggedIn => _auth.currentUser != null;

  /// Send Email Verification Link to Current User
  static Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        debugPrint('Email verification sent to ${user.email}');
      }
    } catch (e) {
      debugPrint('Error sending email verification: $e');
      rethrow;
    }
  }

  /// Check if user's email has been verified (reloads Firebase User state)
  static Future<bool> checkEmailVerifiedStatus() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.reload();
        final updatedUser = _auth.currentUser;
        return updatedUser?.emailVerified ?? false;
      }
      return false;
    } catch (e) {
      debugPrint('Check email verified status warning: $e');
      return false;
    }
  }

  /// Register User with Email and Password
  static Future<UserCredential?> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // 1. Create Auth User
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        // 2. Update Display Name in Firebase User Profile
        await user.updateDisplayName(name.trim());

        // 3. Save User Document to Firestore with current local language preference
        try {
          final currentLocalLang = await SessionManager().getSavedLanguageCode();
          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'name': name.trim(),
            'email': email.trim(),
            'language': currentLocalLang,
            'createdAt': FieldValue.serverTimestamp(),
          });
        } catch (e) {
          debugPrint('Firestore document creation warning: $e');
        }

        // 4. Trigger Email Verification Link
        try {
          await user.sendEmailVerification();
          debugPrint('Verification email sent to ${user.email}');
        } catch (e) {
          debugPrint('Failed to send initial verification email: $e');
        }
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Signup Exception: [${e.code}] ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected Signup Error: $e');
      rethrow;
    }
  }

  /// Login User with Email and Password
  static Future<UserCredential?> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Sign In with Email and Password
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        // Reload user to get latest emailVerified status
        await user.reload();
        final refreshedUser = _auth.currentUser ?? user;

        // 2. Check if email is verified
        if (!refreshedUser.emailVerified) {
          throw FirebaseAuthException(
            code: 'email-not-verified',
            message:
                'Your email address is not verified yet. Please check your inbox and verify your email.',
          );
        }

        String fetchedName = refreshedUser.displayName ?? '';
        String fetchedPhotoBase64 = '';

        // 3. Fetch Name, Photo & Language from Firestore if available
        try {
          final doc = await _firestore
              .collection('users')
              .doc(refreshedUser.uid)
              .get();
          if (doc.exists && doc.data() != null) {
            final data = doc.data()!;
            if (data['name'] != null && data['name'].toString().isNotEmpty) {
              fetchedName = data['name'].toString();
            }
            if (data['photoBase64'] != null &&
                data['photoBase64'].toString().isNotEmpty) {
              fetchedPhotoBase64 = data['photoBase64'].toString();
            }

            // Sync Firestore Language preference to local SharedPreferences and UI
            if (data['language'] != null && data['language'].toString().isNotEmpty) {
              final remoteLang = data['language'].toString();
              await applyAndSaveLanguage(remoteLang);
            } else {
              // If Firestore user doc doesn't have language set, save local language to Firestore
              final localLang = await SessionManager().getSavedLanguageCode();
              await updateUserLanguage(uid: refreshedUser.uid, languageCode: localLang);
            }
          }
        } catch (e) {
          debugPrint('Firestore User Fetch Warning: $e');
        }

        if (fetchedName.isEmpty) {
          fetchedName = email.split('@').first;
        }

        // 4. Save Session locally
        final session = SessionManager();
        await session.setBoolValue(SessionManager.isLogin, true);
        await session.setStringValue(SessionManager.userID, refreshedUser.uid);
        await session.setStringValue(SessionManager.userName, fetchedName);
        await session.setStringValue(
          SessionManager.userEmail,
          refreshedUser.email ?? email.trim(),
        );
        await session.setStringValue(
          SessionManager.userPhotoBase64,
          fetchedPhotoBase64,
        );
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Login Exception: [${e.code}] ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected Login Error: $e');
      rethrow;
    }
  }

  /// Sync User Language from Firestore on app launch
  static Future<void> syncUserLanguageFromFirestore() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final firestoreLang = data['language']?.toString();
        final session = SessionManager();
        final localLang = await session.getSavedLanguageCode();

        if (firestoreLang != null && firestoreLang.isNotEmpty) {
          if (firestoreLang != localLang) {
            debugPrint('Syncing language from Firestore ($firestoreLang) to local SharedPreferences');
            await applyAndSaveLanguage(firestoreLang);
          }
        } else {
          await updateUserLanguage(uid: user.uid, languageCode: localLang);
        }
      }
    } catch (e) {
      debugPrint('Error syncing user language from Firestore: $e');
    }
  }

  /// Helper to apply language globally to SharedPreferences, GetX locale, and active controllers
  static Future<void> applyAndSaveLanguage(String languageCode) async {
    final locale = await SessionManager().setLocale(languageCode);
    Get.updateLocale(locale);
    if (Get.context != null) {
      MyApp.setLocale(Get.context!, locale);
    }
    Get.forceAppUpdate();
  }

  /// Update User Preferred Language in Firestore
  static Future<void> updateUserLanguage({
    required String uid,
    required String languageCode,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'language': languageCode,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint('Firestore user language updated to: $languageCode');
    } catch (e) {
      debugPrint('Error updating language in Firestore: $e');
    }
  }

  /// Update User Name in Firebase Auth, Firestore & SessionManager
  static Future<void> updateUserName({
    required String uid,
    required String name,
  }) async {
    final trimmedName = name.trim();
    try {
      final user = _auth.currentUser;
      final session = SessionManager();

      final futures = <Future<dynamic>>[
        session.setStringValue(SessionManager.userName, trimmedName),
      ];

      if (user != null) {
        futures.add(user.updateDisplayName(trimmedName));
      }

      if (uid.isNotEmpty) {
        futures.add(
          _firestore.collection('users').doc(uid).set({
            'name': trimmedName,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true)),
        );
      }

      await Future.wait(futures);
    } catch (e) {
      debugPrint('Error updating user name: $e');
      rethrow;
    }
  }

  /// Update User Password in Firebase Auth (with Re-authentication)
  static Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user != null && user.email != null) {
        // 1. Re-authenticate user with current password to satisfy Firebase security requirements
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);

        // 2. Update to new password
        await user.updatePassword(newPassword);
      } else {
        throw Exception("User not logged in.");
      }
    } catch (e, stackTrace) {
      debugPrint('[AuthService] Error updating password: $e');
      debugPrint('[AuthService] Password Update StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// Update User Profile Image in Firestore & SessionManager
  static Future<void> updateUserProfileImage({
    required String uid,
    required String base64Image,
  }) async {
    try {
      // 1. Update Firestore Document in 'users' collection
      await _firestore.collection('users').doc(uid).set({
        'photoBase64': base64Image,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 2. Save in SharedPreferences locally
      final session = SessionManager();
      await session.setStringValue(SessionManager.userPhotoBase64, base64Image);
    } catch (e) {
      debugPrint('Error updating profile image in Firestore: $e');
      rethrow;
    }
  }

  /// Sign Out User
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Firebase Signout Warning: $e');
    }
    await SessionManager().onClearSession();
  }

  /// Send Password Reset Email
  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      debugPrint('Password Reset Exception: [${e.code}] ${e.message}');
      rethrow;
    }
  }

  /// Validate Email Address (accepts all standard email formats, business emails, .com, .co.in, .co, etc.)
  static bool isValidStrictEmail(String email) {
    final trimmed = email.trim();
    if (trimmed.isEmpty) return false;

    // Standard valid email regex supporting multi-level domains (.com, .co.in, .co, etc.)
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(trimmed);
  }

  /// Alias for general email validation
  static bool isValidEmail(String email) => isValidStrictEmail(email);

  /// Map Firebase Auth Exceptions to User Friendly Messages
  static String getReadableErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-not-verified':
          return 'Your email address is not verified yet. Please check your Inbox or SPAM folder for the link.';
        case 'email-already-in-use':
          return 'This email address is already registered. Please log in.';
        case 'invalid-email':
          return 'The email address is invalid. Please check your email.';
        case 'operation-not-allowed':
          return 'Email/Password sign in is currently disabled in Firebase.';
        case 'weak-password':
          return 'The password is too weak. Please use at least 6 characters.';
        case 'user-disabled':
          return 'This user account has been disabled.';
        case 'user-not-found':
          return 'No account found with this email. Please sign up.';
        case 'wrong-password':
        case 'invalid-credential':
          return 'Current password is incorrect. Please check and try again.';
        case 'requires-recent-login':
          return 'For security reasons, please log out and log back in before changing your password.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection.';
        default:
          return error.message ?? 'An authentication error occurred.';
      }
    }
    return error.toString();
  }
}
