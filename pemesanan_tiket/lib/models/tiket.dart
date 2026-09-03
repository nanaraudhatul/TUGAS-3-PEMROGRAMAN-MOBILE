import 'package:uuid/uuid.dart';

// =============================================
// ABSTRACT CLASS - Tiket
// =============================================
abstract class Tiket {
  final String id;
  final String nama;
  final double harga;
  final String gambarUrl;
  final DateTime tanggal;
  int stok;

  Tiket({
    String? id,
    required this.nama,
    required this.harga,
    this.gambarUrl = 'https://picsum.photos/400/300',
    required this.tanggal,
    this.stok = 100,
  }) : id = id ?? const Uuid().v4();

  // Abstract method - wajib diimplementasi subclass
  String deskripsi();
  
  bool get tersedia => stok > 0;
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'harga': harga,
      'gambarUrl': gambarUrl,
      'tanggal': tanggal.toIso8601String(),
      'stok': stok,
    };
  }
}

// =============================================
// MIXIN - BisaDiskon
// =============================================
mixin BisaDiskon on Tiket {
  double hitungHargaDiskon(double persen) {
    return harga * (1 - persen / 100);
  }
  
  double get hargaSetelahDiskon => hitungHargaDiskon(10);
  bool get adaDiskon => true;
}

// =============================================
// SUBCLASS - TiketEkonomi
// =============================================
class TiketEkonomi extends Tiket {
  final String fasilitas;
  
  TiketEkonomi({
    super.id,
    required super.nama,
    required super.harga,
    super.gambarUrl,
    required super.tanggal,
    super.stok,
    this.fasilitas = 'Kursi reguler, akses standar',
  });

  @override
  String deskripsi() {
    return 'Tiket Ekonomi untuk "$nama" — $fasilitas. '
        'Cocok untuk Anda yang ingin menikmati acara dengan budget terjangkau.';
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'tipe': 'ekonomi',
      'fasilitas': fasilitas,
    };
  }
}

// =============================================
// SUBCLASS - TiketVIP (dengan mixin BisaDiskon)
// =============================================
class TiketVIP extends Tiket with BisaDiskon {
  final List<String> fasilitasPremium;
  
  TiketVIP({
    super.id,
    required super.nama,
    required super.harga,
    super.gambarUrl,
    required super.tanggal,
    super.stok,
    this.fasilitasPremium = const ['Kursi VIP baris depan', 'Akses backstage', 'Meet & greet'],
  });

  @override
  String deskripsi() {
    return 'Tiket VIP untuk "$nama" — Fasilitas: ${fasilitasPremium.join(", ")}. '
        'Pengalaman terbaik dengan akses eksklusif!';
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'tipe': 'vip',
      'fasilitasPremium': fasilitasPremium,
    };
  }
}

// =============================================
// SUBCLASS - TiketPremium (dengan mixin BisaDiskon)
// =============================================
class TiketPremium extends Tiket with BisaDiskon {
  final bool includeMerchandise;
  
  TiketPremium({
    super.id,
    required super.nama,
    required super.harga,
    super.gambarUrl,
    required super.tanggal,
    super.stok,
    this.includeMerchandise = true,
  });

  @override
  String deskripsi() {
    return 'Tiket Premium untuk "$nama" — Kursi terbaik di venue, lounge eksklusif, '
        '${includeMerchandise ? "merchandise eksklusif, " : ""}dan goodie bag premium.';
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'tipe': 'premium',
      'includeMerchandise': includeMerchandise,
    };
  }
}

// =============================================
// CLASS - PemesananTiket
// =============================================
class PemesananTiket {
  final String id;
  final Tiket tiket;
  final DateTime tanggalPesan;
  final double hargaBayar;
  final String status;
  
  PemesananTiket({
    String? id,
    required this.tiket,
    required this.tanggalPesan,
    required this.hargaBayar,
    this.status = 'confirmed',
  }) : id = id ?? const Uuid().v4();
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tiket': tiket.toJson(),
      'tanggalPesan': tanggalPesan.toIso8601String(),
      'hargaBayar': hargaBayar,
      'status': status,
    };
  }
  
  factory PemesananTiket.fromJson(Map<String, dynamic> json) {
    return PemesananTiket(
      id: json['id'],
      tiket: _parseTiket(json['tiket']),
      tanggalPesan: DateTime.parse(json['tanggalPesan']),
      hargaBayar: json['hargaBayar'],
      status: json['status'],
    );
  }
  
  static Tiket _parseTiket(Map<String, dynamic> json) {
    switch (json['tipe']) {
      case 'vip':
        return TiketVIP(
          id: json['id'],
          nama: json['nama'],
          harga: json['harga'],
          gambarUrl: json['gambarUrl'],
          tanggal: DateTime.parse(json['tanggal']),
          stok: json['stok'],
        );
      case 'premium':
        return TiketPremium(
          id: json['id'],
          nama: json['nama'],
          harga: json['harga'],
          gambarUrl: json['gambarUrl'],
          tanggal: DateTime.parse(json['tanggal']),
          stok: json['stok'],
        );
      default:
        return TiketEkonomi(
          id: json['id'],
          nama: json['nama'],
          harga: json['harga'],
          gambarUrl: json['gambarUrl'],
          tanggal: DateTime.parse(json['tanggal']),
          stok: json['stok'],
        );
    }
  }
}