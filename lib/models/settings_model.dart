// settings_model.dart
import 'package:flutter/material.dart';
import 'package:jebek_app/services/purchase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TruthFormat { vf, binary } // V/F  o  1/0

enum MintermOrder { asc, desc }

enum KeypadMode { advanced, simple }

class Settings extends ChangeNotifier {
  bool isProVersion = false;

  final PurchaseService _purchaseService = PurchaseService();

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    // Escuchar cambios del estado Pro
    _purchaseService.isProVersion.addListener(() {
      isProVersion = _purchaseService.isProVersion.value;
      notifyListeners();
    });

    // Inicializar listener y restaurar compras
    _purchaseService.initPurchaseListener();
    await _purchaseService.restorePurchases();

    // Leer local por si ya se activó previamente (fallback)
    final localFlag = prefs.getBool('isProVersion') ?? false;
    if (!isProVersion && localFlag) {
      isProVersion = true;
      notifyListeners();
    }

    notifyListeners();
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await load();
  }

  Future<void> activateProLocally() async {
    final prefs = await SharedPreferences.getInstance();
    isProVersion = true;
    await prefs.setBool('isProVersion', true);
    notifyListeners();
  }

  Future<void> buyPro() async {
    await _purchaseService.buyProVersion();
  }
}
