import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/tiket.dart';
import '../services/tiket_service.dart';
import '../services/storage_service.dart';
import '../exceptions/tiket_exceptions.dart';

class TiketProvider extends ChangeNotifier {
  final TiketService _service;
  final StorageService _storage;
  
  List<Tiket> _daftarTiket = [];
  List<PemesananTiket> _pemesananSaya = [];
  bool _isLoading = false;
  String? _error;
  int _promoWaktuSisa = 30;
  
  TiketProvider({
    required TiketService service,
    required StorageService storage,
  })  : _service = service,
        _storage = storage {
    _startPromoCountdown();
    loadPemesananSaya();
  }
  
  List<Tiket> get daftarTiket => _daftarTiket;
  List<PemesananTiket> get pemesananSaya => _pemesananSaya;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get promoWaktuSisa => _promoWaktuSisa;
  bool get adaError => _error != null;
  
  Future<void> loadDaftarTiket({bool forceRefresh = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _daftarTiket = await _service.ambilDaftarTiket(forceRefresh: forceRefresh);
    } on NetworkException catch (e) {
      _error = e.toString();
    } on Exception catch (e) {
      _error = 'Terjadi kesalahan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<PemesananTiket?> prosesPemesanan(Tiket tiket, {bool gunakanDiskon = false}) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final hasil = await _service.pesanTiket(tiket);
      
      double hargaBayar = gunakanDiskon && tiket is BisaDiskon 
          ? tiket.hargaSetelahDiskon 
          : tiket.harga;
      
      final pemesanan = PemesananTiket(
        tiket: tiket,
        tanggalPesan: DateTime.now(),
        hargaBayar: hargaBayar,
      );
      
      await _storage.savePemesanan(pemesanan);
      await loadPemesananSaya();
      
      Get.snackbar(
        '✅ Berhasil!',
        hasil,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );
      
      return pemesanan;
      
    } on TiketHabisException catch (e) {
      Get.snackbar(
        '❌ Tiket Habis',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      rethrow;
      
    } catch (e) {
      Get.snackbar(
        '⚠️ Error',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
      );
      return null;
      
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> loadPemesananSaya() async {
    _pemesananSaya = await _storage.getPemesanan();
    notifyListeners();
  }
  
  void _startPromoCountdown() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_promoWaktuSisa > 0) {
        _promoWaktuSisa--;
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }
  
  void resetPromo() {
    _promoWaktuSisa = 30;
    notifyListeners();
  }
  
  Future<void> refreshData() async {
    _service.clearCache();
    await loadDaftarTiket(forceRefresh: true);
  }
}
