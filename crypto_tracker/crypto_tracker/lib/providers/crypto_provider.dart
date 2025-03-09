import 'package:flutter/material.dart';
import 'package:crypto_tracker/models/crypto_model.dart';
import 'package:crypto_tracker/services/crypto_service.dart';

class CryptoProvider extends ChangeNotifier {
  final CryptoService _cryptoService = CryptoService();
  List<Crypto> _cryptos = [];
  bool _isLoading = false;
  String _error = '';

  List<Crypto> get cryptos => _cryptos;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchCryptos() async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      _cryptos = await _cryptoService.getTopCryptos();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getCryptoDetails(String id) async {
    try {
      return await _cryptoService.getCryptoDetails(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
} 