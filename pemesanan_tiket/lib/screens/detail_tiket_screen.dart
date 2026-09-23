import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/tiket.dart';
import 'pesan_tiket_screen.dart';

class DetailTiketScreen extends StatelessWidget {
  final Tiket tiket;
  
  const DetailTiketScreen({super.key, required this.tiket});
  
  @override
  Widget build(BuildContext context) {
    final bisaDiskon = tiket is BisaDiskon;
    final hargaAkhir = bisaDiskon ? (tiket as BisaDiskon).hargaSetelahDiskon : tiket.harga;
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(tiket.nama, style: const TextStyle(shadows: [Shadow(color: Colors.black54, blurRadius: 4)])),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // ✅ GUNAKAN Image.network
                  Image.network(
                    tiket.gambarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade400),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Detail Tiket', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  
                  if (bisaDiskon) ...[
                    Text(
                      'Rp ${tiket.harga.toStringAsFixed(0)}',
                      style: TextStyle(fontSize: 18, color: Colors.grey.shade500, decoration: TextDecoration.lineThrough),
                    ),
                    Text(
                      'Rp ${hargaAkhir.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 28, color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Diskon 10% untuk pembelian hari ini!',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ] else
                    Text(
                      'Rp ${tiket.harga.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  
                  const SizedBox(height: 24),
                  
                  const Text('Deskripsi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(tiket.deskripsi(), style: const TextStyle(height: 1.6)),
                  
                  const SizedBox(height: 24),
                  
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildInfoRow(Icons.calendar_today, 'Tanggal: ${tiket.tanggal.day}/${tiket.tanggal.month}/${tiket.tanggal.year}'),
                          const SizedBox(height: 8),
                          _buildInfoRow(Icons.inventory, 'Stok tersedia: ${tiket.stok}'),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: tiket.tersedia
                          ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => PesanTiketScreen(tiket: tiket)))
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        tiket.tersedia ? 'Pesan Sekarang' : 'Sold Out',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(width: 12),
        Text(text),
      ],
    );
  }
}
