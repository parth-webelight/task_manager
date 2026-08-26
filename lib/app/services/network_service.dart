import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_manager/app/core/utils/alert_message_utils.dart';

class NetworkService extends GetxService {
  static NetworkService get to => Get.find<NetworkService>();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  final RxBool isConnected = true.obs;
  final RxBool showRestoredBanner = false.obs;
  bool _wasOffline = false;

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _subscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _initConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      await _updateConnectionStatus(results);
    } catch (e) {
      debugPrint('Connectivity init error: $e');
    }
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> results) async {
    final hasConnectionResult = results.any((r) => r != ConnectivityResult.none);
    
    bool hasRealInternet = false;
    if (hasConnectionResult) {
      hasRealInternet = await _checkRealInternetAccess();
    }

    if (!hasRealInternet) {
      isConnected.value = false;
      _wasOffline = true;
      showRestoredBanner.value = false;
    } else {
      if (_wasOffline) {
        // Device came back online!
        showRestoredBanner.value = true;
        _wasOffline = false;
        Future.delayed(const Duration(milliseconds: 2800), () {
          showRestoredBanner.value = false;
        });
      }
      isConnected.value = true;
    }
  }

  /// Lightweight lookup to confirm actual internet access
  Future<bool> _checkRealInternetAccess() async {
    try {
      final result = await InternetAddress.lookup('google.com').timeout(
        const Duration(seconds: 3),
      );
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Helper method to check online status before executing internet operations
  static bool checkOnlineOrShowAlert({String? customMessage}) {
    if (Get.isRegistered<NetworkService>()) {
      final networkService = NetworkService.to;
      if (!networkService.isConnected.value) {
        if (Get.isRegistered<AlertMessageUtils>()) {
          Get.find<AlertMessageUtils>().showWarningSnackBar(
            title: 'No Internet Connection',
            message: customMessage ?? 'Please check your internet connection and try again.',
          );
        }
        return false;
      }
    }
    return true;
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
