import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tiket.dart';
import '../providers/tiket_provider.dart';
import '../exceptions/tiket_exceptions.dart';

class PesanTiketScreen extends StatefulWidget {
  final Tiket tiket;
  
  const PesanTiketScreen({super.key, required this.tiket});
  
  @override
  State<PesanTiketScreen> createState() => _PesanTiketScreenState();
}

class _PesanTiketScreenState extends State<PesanTiketScreen> {
  bool _gunakanDiskon = false;
  
  @override
  Widget build(BuildContext context) {
    final bisaDiskon = widget.tiket is BisaDiskon;
    final harga = _gunakanDiskon && bisaDiskon 
        ? (widget.tiket as BisaDiskon).hargaSetelahDiskon 
        : widget.tiket.harga;
    
    return Scaffold(
      appBar: AppBar(title: const Text('Konfirmasi Pemesanan')),
      body: Consumer<TiketProvider>(
        builder: (context, provider, _) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                if (provider.isLoading)
                  const CircularProgressIndicator()
                else
                  const Icon(Icons.confirmation_number, size: 100, color: Colors.blue),
                
                const SizedBox(height: 24),
                
                Text(widget.tiket.nama, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text('Rp ${harga.toStringAsFixed(0)}', style: TextStyle(fontSize: 20, color: Colors.grey.shade600)),
                
                if (bisaDiskon) ...[
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Gunakan diskon 10%'),
                    subtitle: Text('Hemat Rp ${(widget.tiket.harga - (widget.tiket as BisaDiskon).hargaSetelahDiskon).toStringAsFixed(0)}'),
                    value: _gunakanDiskon,
                    onChanged: (v) => setState(() => _gunakanDiskon = v),
                  ),
                ],
                
                const Spacer(),
                
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: provider.isLoading ? null : () => _konfirmasiPemesanan(provider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: provider.isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Konfirmasi & Bayar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Future<void> _konfirmasiPemesanan(TiketProvider provider) async {
    try {
      await provider.prosesPemesanan(widget.tiket, gunakanDiskon: _gunakanDiskon);
      
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_circle, size: 50, color: Colors.blue.shade700),
                ),
                const SizedBox(height: 20),
                const Text('Pemesanan Berhasil!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                const Text('Tiket telah tersimpan di "Tiket Saya"', textAlign: TextAlign.center),
              ],
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.popUntil(context, (r) => r.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Lihat Tiket Saya'),
                ),
              ),
            ],
          ),
        );
      }
    } on TiketHabisException catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.error_outline, size: 50, color: Colors.red),
                ),
                const SizedBox(height: 20),
                const Text('Oops, Tiket Habis!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(e.toString(), textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(height: 8),
                const Text('Acara berikutnya akan segera hadir!', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              ],
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Kunjungi Acara Lain'),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Error'),
            content: Text('Terjadi kesalahan: $e'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
            ],
          ),
        );
      }
    }
  }
}
