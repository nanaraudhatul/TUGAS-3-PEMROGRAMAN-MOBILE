import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/tiket.dart';
import '../exceptions/tiket_exceptions.dart';

class TiketService {
  final Dio _dio;
  List<Tiket>? _cachedTickets;
  DateTime? _cacheTime;
  
  TiketService({Dio? dio}) : _dio = dio ?? Dio();
  
  Future<List<Tiket>> ambilDaftarTiket({bool forceRefresh = false}) async {
    if (_cachedTickets != null && 
        _cacheTime != null && 
        !forceRefresh && 
        DateTime.now().difference(_cacheTime!).inMinutes < 5) {
      return _cachedTickets!;
    }
    
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      if (_cachedTickets != null) {
        return _cachedTickets!;
      }
      throw NetworkException('Tidak ada koneksi internet', statusCode: 0);
    }
    
    await Future.delayed(const Duration(seconds: 1));
    
    // ✅ URL GAMBAR YANG PASTI BISA DI-LOAD (dari Unsplash)
    final tickets = [
      TiketVIP(
        nama: 'Konser Musik Akbar',
        harga: 1500000,
        tanggal: DateTime.now().add(const Duration(days: 30)),
        stok: 50,
        gambarUrl: 'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=400&h=400&fit=crop',
      ),
      TiketEkonomi(
        nama: 'Konser Band',
        harga: 166000,
        tanggal: DateTime.now().add(const Duration(days: 15)),
        stok: 200,
        gambarUrl: 'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?w=400&h=400&fit=crop',
      ),
      TiketPremium(
        nama: 'Konser Music',
        harga: 500000,
        tanggal: DateTime.now().add(const Duration(days: 7)),
        stok: 30,
        gambarUrl: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=400&h=400&fit=crop',
      ),
      TiketEkonomi(
        nama: 'Festival Band music',
        harga: 250000,
        tanggal: DateTime.now().add(const Duration(days: 45)),
        stok: 150,
        gambarUrl: 'https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3?w=400&h=400&fit=crop',
      ),
      TiketVIP(
        nama: 'Festival Music',
        harga: 1500000,
        tanggal: DateTime.now().add(const Duration(days: 15)),
        stok: 25,
        gambarUrl: 'https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=400&h=400&fit=crop',
      ),
    ];
    
    _cachedTickets = tickets;
    _cacheTime = DateTime.now();
    
    return tickets;
  }
  
  Future<String> pesanTiket(Tiket tiket) async {
    await Future.delayed(const Duration(seconds: 1));
    
    if (Random().nextDouble() < 0.4) {
      throw TiketHabisException(
        tiket.nama,
        'Maaf, tiket untuk "${tiket.nama}" sudah terjual habis.',
      );
    }
    
    return 'Pemesanan berhasil! Tiket "${tiket.nama}" telah tersimpan di "Tiket Saya".';
  }
  
  Future<void> simpanPemesanan(PemesananTiket pemesanan) async {
    await _dio.post('/api/pemesanan', data: pemesanan.toJson());
  }
  
  void clearCache() {
    _cachedTickets = null;
    _cacheTime = null;
  }
}
