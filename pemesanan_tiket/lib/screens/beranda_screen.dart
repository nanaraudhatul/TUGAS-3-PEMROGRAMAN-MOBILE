import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/tiket_provider.dart';
import '../models/tiket.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/countdown_timer.dart';
import 'detail_tiket_screen.dart';
import 'tiket_saya_screen.dart';
import 'profil_screen.dart';

class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key});
  
  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  int _selectedIndex = 0;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TiketProvider>().loadDaftarTiket();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda Acara'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildBerandaTab(),
          const TiketSayaScreen(),
          const ProfilScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        selectedItemColor: Colors.blue,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.confirmation_number), label: 'Tiket Saya'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
  
  Widget _buildBerandaTab() {
    return Consumer<TiketProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Promo Banner dengan Countdown
              _buildPromoBanner(provider.promoWaktuSisa),
              
              // Featured Events
              SizedBox(
                height: 200,
                child: PageView.builder(
                  itemCount: 3,
                  itemBuilder: (context, index) => _buildFeaturedCard(index),
                ),
              ),
              
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Acara Populer', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              
              // FutureBuilder dengan Provider
              if (provider.isLoading)
                const TiketShimmerList()
              else if (provider.adaError)
                _buildErrorWidget(provider.error!)
              else
                _buildTicketList(provider.daftarTiket),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildPromoBanner(int sisaWaktu) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue.shade400, Colors.blue.shade700]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_offer, color: Colors.white, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Penawaran Spesial!', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const Text('Diskon 10% untuk tiket VIP & Premium', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                CountdownTimer(seconds: sisaWaktu),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFeaturedCard(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: CachedNetworkImageProvider('https://picsum.photos/seed/featured$index/400/300'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Event Highlight', style: TextStyle(color: Colors.white70)),
              Text('Konser Musik Akbar 2024', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(Icons.wifi_off, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(error, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.read<TiketProvider>().loadDaftarTiket(),
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTicketList(List<Tiket> tickets) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        final tiket = tickets[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DetailTiketScreen(tiket: tiket)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: tiket.gambarUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      placeholder: (c, u) => Container(color: Colors.grey.shade300),
                      errorWidget: (c, u, e) => Container(color: Colors.grey.shade300),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tiket.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Rp ${tiket.harga.toStringAsFixed(0)}', style: TextStyle(color: Colors.grey.shade600)),
                        if (tiket is BisaDiskon) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(4)),
                            child: Text('Diskon 10%', style: TextStyle(color: Colors.green.shade700, fontSize: 10)),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}