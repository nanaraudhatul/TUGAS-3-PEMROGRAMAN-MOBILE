void main() {
  // 1. Map berisi minimal 5 mahasiswa
  // 'absensi' di sini diasumsikan sebagai jumlah ketidakhadiran (alpha)
  Map<String, Map<String, dynamic>> dataMahasiswa = {
    'Raudhatul': {
      'nilai': [90, 95, 88, 92, 94],
      'absensi': 0,
    },
    'Putri Maharani': {
      'nilai': [85, 90, 78, 92, 88],
      'absensi': 1,
          
    },
    'Jiyhan Rusdin': {
      'nilai': [70, 75, 80, 65, 72],
      'absensi': 2,
    },
    'Melati': {
      'nilai': [55, 60, 58, 52, 45],
      'absensi': 4, // Alpha > 3, sehingga tidak lulus meskipun ada nilai di atas 60,
    },
  };

  // List untuk menampung semua nilai individu guna menghitung statistik kelas
  List<int> semuaNilaiKelas = [];

  // === LAPORAN NILAI MAHASISWA ===
  print('=== LAPORAN NILAI MAHASISWA ===');

  for (var entry in dataMahasiswa.entries) {
    String nama = entry.key;
    List<int> nilai = List<int>.from(entry.value['nilai']);
    int absensi = entry.value['absensi'];

    // Tambahkan nilai ke list statistik kelas
    semuaNilaiKelas.addAll(nilai);

    // Hitung menggunakan fungsi yang telah dibuat
    double rataRata = hitungRataRata(nilai);
    String grade = tentukanGrade(rataRata);
    bool lulus = cekKelulusan(rataRata: rataRata, absensi: absensi);
    String status = lulus ? 'LULUS' : 'TIDAK LULUS';

    // Cetak laporan per mahasiswa
    print('Nama      : $nama');
    print('Nilai     : $nilai');
    print('Rata-rata : ${rataRata.toStringAsFixed(1)}');
    print('Grade     : $grade');
    print('Status    : $status');
    print(''); // Baris kosong pemisah
  }

  // === STATISTIK KELAS ===
  // Mencari nilai tertinggi dan terendah dari seluruh nilai individu
  int nilaiTertinggi = semuaNilaiKelas.reduce((a, b) => a > b ? a : b);
  int nilaiTerendah = semuaNilaiKelas.reduce((a, b) => a < b ? a : b);
  double rataRataKelas = hitungRataRata(semuaNilaiKelas);

  print('=== STATISTIK KELAS ===');
  print('Nilai Tertinggi : $nilaiTertinggi');
  print('Nilai Terendah  : $nilaiTerendah');
  print('Rata-rata Kelas : ${rataRataKelas.toStringAsFixed(1)}');
}

// 2. Fungsi untuk menghitung rata-rata nilai
double hitungRataRata(List<int> nilai) {
  if (nilai.isEmpty) return 0.0;
  int total = 0;
  for (int n in nilai) {
    total += n;
  }
  return total / nilai.length;
}

// 3. Fungsi untuk menentukan grade
String tentukanGrade(double rataRata) {
  if (rataRata >= 85) return 'A';
  if (rataRata >= 75) return 'B';
  if (rataRata >= 65) return 'C';
  if (rataRata >= 50) return 'D';
  return 'E';
}

// 4. Fungsi untuk mengecek kelulusan
bool cekKelulusan({required double rataRata, required int absensi}) {
  return rataRata >= 60 && absensi <= 3;
}
