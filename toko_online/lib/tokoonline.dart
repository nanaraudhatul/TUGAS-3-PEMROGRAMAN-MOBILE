import 'dart:io';

// ============ CUSTOM EXCEPTIONS ============
class StokHabisException implements Exception {
  final String nama;
  StokHabisException(this.nama);
  @override
  String toString() => 'Stok "$nama" telah habis!';
}

class ProdukTidakAda implements Exception {
  final String keyword;
  ProdukTidakAda(this.keyword);
  @override
  String toString() => 'Produk "$keyword" tidak ditemukan!';
}

// ============ ABSTRACT CLASS PRODUK ============
abstract class Produk {
  final String id;
  final String nama;
  final double harga;
  int stok;

  Produk(this.id, this.nama, this.harga, this.stok);

  String deskripsi();

  @override
  String toString() => '[$id] $nama - Rp${harga.toStringAsFixed(0)} (Stok: $stok)';
}

// ============ MIXIN BISA DISKON ============
mixin BisaDiskon on Produk {
  void validasiDiskon(double persen) {
    if (persen < 0 || persen > 100) {
      throw Exception('Diskon tidak valid: $persen%');
    }
  }

  double hitungHargaDiskon(double persen) {
    validasiDiskon(persen);
    return harga - (harga * persen / 100);
  }
}

// ============ PRODUK DIGITAL ============
class ProdukDigital extends Produk with BisaDiskon {
  final double ukuranMB;
  final String formatFile;

  ProdukDigital(String id, String nama, double harga, int stok,
      this.ukuranMB, this.formatFile)
      : super(id, nama, harga, stok);

  @override
  String deskripsi() =>
      'DIGITAL | $nama | ${formatFile.toUpperCase()} ${ukuranMB}MB | Rp${harga.toStringAsFixed(0)}';
}

// ============ PRODUK FISIK ============
class ProdukFisik extends Produk with BisaDiskon {
  final int beratGram;
  final String dimensi;

  ProdukFisik(String id, String nama, double harga, int stok,
      this.beratGram, this.dimensi)
      : super(id, nama, harga, stok);

  @override
  String deskripsi() =>
      'FISIK   | $nama | ${beratGram}g ($dimensi) | Rp${harga.toStringAsFixed(0)}';
}

// ============ KERANJANG ============
class Keranjang {
  final List<Produk> items = [];

  void tambah(Produk p) {
    if (p.stok <= 0) throw StokHabisException(p.nama);
    items.add(p);
    print('  [BERHASIL] ${p.nama} ditambahkan ke keranjang');
  }

  void hapus(String id) {
    final idx = items.indexWhere((p) => p.id == id);
    if (idx == -1) throw ProdukTidakAda(id);
    items.removeAt(idx);
    print('  [BERHASIL] Produk dihapus dari keranjang');
  }

  double totalHarga() => items.fold(0, (sum, p) => sum + p.harga);

  void tampilkan() {
    if (items.isEmpty) {
      print('  Keranjang kosong.');
      return;
    }
    for (var p in items) {
      print('  - ${p.nama}: Rp${p.harga.toStringAsFixed(0)}');
    }
    print('  Total: Rp${totalHarga().toStringAsFixed(0)}');
  }
}

// ============ TOKO SERVICE (ASYNC) ============
class TokoService {
  final List<Produk> katalog;
  TokoService(this.katalog);

  Future<List<Produk>> cariProduk(String keyword) async {
    await Future.delayed(Duration(milliseconds: 300));
    final hasil = katalog
        .where((p) => p.nama.toLowerCase().contains(keyword.toLowerCase()))
        .toList();
    if (hasil.isEmpty) throw ProdukTidakAda(keyword);
    return hasil;
  }

  Future<void> prosesCheckout(Keranjang keranjang) async {
    print('  [PROSES] Memproses checkout...');
    await Future.delayed(Duration(milliseconds: 500));

    for (var p in keranjang.items) {
      if (p.stok <= 0) throw StokHabisException(p.nama);
      p.stok--;
    }

    print('  [BERHASIL] Checkout selesai! Total: Rp${keranjang.totalHarga().toStringAsFixed(0)}');
  }
}

// ============ HELPER INPUT ============
String? input(String prompt) {
  stdout.write(prompt);
  return stdin.readLineSync()?.trim();
}

// ============ MAIN ============
void main() async {
  final katalog = <Produk>[
    ProdukDigital('D1', 'E-Book Dart', 75000, 10, 12.5, 'pdf'),
    ProdukDigital('D2', 'Course Flutter', 500000, 3, 1200, 'mp4'),
    ProdukFisik('F1', 'Kaos Dart', 150000, 5, 250, '30x25x2'),
    ProdukFisik('F2', 'Mug Logo', 85000, 20, 400, '12x10x10'),
  ];

  final toko = TokoService(katalog);
  final keranjang = Keranjang();

  bool jalan = true;
  while (jalan) {
    print('\n=== TOKO ONLINE DART ===');
    print('1. Lihat Produk');
    print('2. Cari Produk');
    print('3. Tambah ke Keranjang');
    print('4. Lihat Keranjang');
    print('5. Hapus dari Keranjang');
    print('6. Checkout');
    print('7. Demo Diskon');
    print('0. Keluar');

    try {
      final pilih = input('Pilih: ');
      switch (pilih) {
        case '1':
          print('\n-- Daftar Produk --');
          for (var p in katalog) {
            print('  ${p.deskripsi()}');
          }
          break;

        case '2':
          final kw = input('Kata kunci: ') ?? '';
          try {
            final hasil = await toko.cariProduk(kw);
            print('\nDitemukan ${hasil.length} produk:');
            for (var p in hasil) {
              print('  ${p.deskripsi()}');
            }
          } on ProdukTidakAda catch (e) {
            print('  [ERROR] $e');
          }
          break;

        case '3':
          final id = input('ID produk: ') ?? '';
          try {
            final produk = katalog.firstWhere((p) => p.id == id);
            keranjang.tambah(produk);
          } on StateError {
            print('  [ERROR] ID tidak ditemukan!');
          } on StokHabisException catch (e) {
            print('  [ERROR] $e');
          }
          break;

        case '4':
          print('\n-- Keranjang --');
          keranjang.tampilkan();
          break;

        case '5':
          final id = input('ID produk: ') ?? '';
          try {
            keranjang.hapus(id);
          } on ProdukTidakAda catch (e) {
            print('  [ERROR] $e');
          }
          break;

        case '6':
          try {
            await toko.prosesCheckout(keranjang);
            keranjang.items.clear();
          } on StokHabisException catch (e) {
            print('  [ERROR] $e');
          }
          break;

        case '7':
          final id = input('ID produk: ') ?? '';
          final persenStr = input('Diskon (%): ') ?? '0';
          try {
            final produk = katalog.firstWhere((p) => p.id == id);
            if (produk is BisaDiskon) {
              final persen = double.parse(persenStr);
              final hargaBaru = produk.hitungHargaDiskon(persen);
              print('  [BERHASIL] Harga setelah diskon $persen%: Rp${hargaBaru.toStringAsFixed(0)}');
            } else {
              print('  [ERROR] Produk tidak mendukung diskon');
            }
          } on FormatException {
            print('  [ERROR] Input angka tidak valid!');
          } on StateError {
            print('  [ERROR] ID tidak ditemukan!');
          } catch (e) {
            print('  [ERROR] $e');
          }
          break;

        case '0':
          jalan = false;
          print('\n[SELESAI] Terima kasih telah menggunakan sistem ini!');
          break;

        default:
          print('[ERROR] Pilihan tidak valid!');
      }
    } catch (e) {
      print('[ERROR] $e');
    }
  }
}