import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tiket.dart';

class StorageService {
  static const String _keyPemesanan = 'pemesanan_tiket';
  final SharedPreferences _prefs;
  
  StorageService(this._prefs);
  
  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }
  
  Future<List<PemesananTiket>> getPemesanan() async {
    final data = _prefs.getStringList(_keyPemesanan) ?? [];
    return data.map((json) => PemesananTiket.fromJson(jsonDecode(json))).toList();
  }
  
  Future<void> savePemesanan(PemesananTiket pemesanan) async {
    final list = await getPemesanan();
    list.add(pemesanan);
    
    final jsonList = list.map((p) => jsonEncode(p.toJson())).toList();
    await _prefs.setStringList(_keyPemesanan, jsonList);
  }
  
  Future<void> clearPemesanan() async {
    await _prefs.remove(_keyPemesanan);
  }
}