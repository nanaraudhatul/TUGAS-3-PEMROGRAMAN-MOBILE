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
  final PageController _pageController = PageController();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TiketProvider>().loadDaftarTiket();
    });
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildBerandaTab(),
          const TiketSayaScreen(),
          const ProfilScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) {
          setState(() => _selectedIndex = i);
          _pageController.jumpToPage(i);
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
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
        return RefreshIndicator(
          onRefresh: () => provider.refreshData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPromoBanner(provider.promoWaktuSisa),
                
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
                
                if (provider.isLoading)
                  const TiketShimmerList()
                else if (provider.adaError)
                  _buildErrorWidget(provider.error!)
                else
                  _buildTicketList(provider.daftarTiket),
              ],
            ),
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
        gradient: const LinearGradient(colors: [Colors.blue, Colors.blueAccent]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_offer, color: Colors.white, size: 32),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Penawaran Spesial!', style: TextStyle(color: Colors.white70, fontSize: 12)),
                Text('Diskon 10% untuk tiket VIP & Premium', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
              ],
            ),
          ),
          CountdownTimer(seconds: sisaWaktu),
        ],
      ),
    );
  }
  
  Widget _buildFeaturedCard(int index) {
    final images = [
      'https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?w=400',
      'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=400',
      'https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3?w=400',
    ];
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: CachedNetworkImageProvider(images[index]),
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
              Text('Konser Musik 2024', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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
            Icon(Icons.wifi_off, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(error, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.read<TiketProvider>().refreshData(),
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
          key: ValueKey('ticket-${tiket.id}-${DateTime.now().millisecondsSinceEpoch}'),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: InkWell(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailTiketScreen(tiket: tiket),
                ),
              );
              // ✅ Clear cache dan refresh saat kembali
              if (mounted) {
                CachedNetworkImage.evictFromCache(tiket.gambarUrl);
                setState(() {});
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // ✅ GUNAKAN Image.network BUKAN CachedNetworkImage
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      tiket.gambarUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      key: ValueKey('img-${tiket.id}'),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey.shade300,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        print('❌ Error loading image: $error');
                        return Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tiket.nama,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rp ${tiket.harga.toStringAsFixed(0)}',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        if (tiket is BisaDiskon) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Diskon 10%',
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.grey.shade400),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
