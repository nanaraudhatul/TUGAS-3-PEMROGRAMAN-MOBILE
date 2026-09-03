import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/tiket.dart';
import '../exceptions/tiket_exceptions.dart';

class TiketService {
  final Dio _dio;
  
  TiketService({Dio? dio}) : _dio = dio ?? Dio();
  
  // =============================================
  // ASYNC FUNCTION - ambilDaftarTiket()
  // =============================================
  Future<List<Tiket>> ambilDaftarTiket() async {
    // Cek koneksi internet
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw NetworkException('Tidak ada koneksi internet', statusCode: 0);
    }
    
    // Simulasi network delay 2 detik
    await Future.delayed(const Duration(seconds: 2));
    
    // Simulasi error acak (15% kemungkinan gagal)
    if (Random().nextDouble() < 0.15) {
      throw NetworkException('Gagal memuat data dari server', statusCode: 500);
    }
    
    // Return data dummy
    return [
      TiketVIP(
        nama: 'Konser Musik Akbar',
        harga: 1500000,
        tanggal: DateTime.now().add(const Duration(days: 30)),
        stok: 50,
        gambarUrl: 'https://picsum.photos/seed/konser1/400/300',
      ),
      TiketEkonomi(
        nama: 'Seminar Teknologi Nasional',
        harga: 166000,
        tanggal: DateTime.now().add(const Duration(days: 15)),
        stok: 200,
        gambarUrl: 'https://picsum.photos/seed/seminar1/400/300',
      ),
      TiketPremium(
        nama: 'FutureBuilder Workshop',
        harga: 500000,
        tanggal: DateTime.now().add(const Duration(days: 7)),
        stok: 30,
        gambarUrl: 'https://picsum.photos/seed/workshop1/400/300',
      ),
      TiketEkonomi(
        nama: 'Kursi Ekonomi Nymah & Lounge',
        harga: 250000,
        tanggal: DateTime.now().add(const Duration(days: 45)),
        stok: 150,
        gambarUrl: 'https://picsum.photos/seed/lounge1/400/300',
      ),
      TiketVIP(
        nama: 'Seminar Teknologi Nasional',
        harga: 1500000,
        tanggal: DateTime.now().add(const Duration(days: 15)),
        stok: 25,
        gambarUrl: 'https://picsum.photos/seed/seminar2/400/300',
      ),
    ];
  }
  
  // =============================================
  // ASYNC FUNCTION - pesanTiket() + Exception
  // =============================================
  Future<String> pesanTiket(Tiket tiket) async {
    // Simulasi network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Simulasi sold out acak (40% kemungkinan)
    if (Random().nextDouble() < 0.4) {
      throw TiketHabisException(
        tiket.nama,
        'Maaf, tiket untuk "${tiket.nama}" sudah terjual habis.',
      );
    }
    
    // Simulasi sukses
    return 'Pemesanan berhasil! Tiket "${tiket.nama}" telah tersimpan di "Tiket Saya".';
  }
  
  // =============================================
  // ASYNC FUNCTION - simpanPemesanan()
  // =============================================
  Future<void> simpanPemesanan(PemesananTiket pemesanan) async {
    // Simulasi API POST
    await _dio.post('/api/pemesanan', data: pemesanan.toJson());
  }
}