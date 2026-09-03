import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tiket_provider.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, size: 50, color: Colors.blue.shade700),
            ),
            const SizedBox(height: 16),
            const Text('Raudhatul', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('nanaraudhatul201@gmail.com', style: TextStyle(color: const Color.fromARGB(255, 120, 107, 107))),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  _buildMenuItem(Icons.confirmation_number, 'Tiket Saya', () {}),
                  const SizedBox(height: 12),
                  _buildMenuItem(Icons.settings, 'Pengaturan', () {}),
                  const SizedBox(height: 12),
                  _buildMenuItem(Icons.help_outline, 'Bantuan', () {}),
                  const SizedBox(height: 12),
                  _buildMenuItem(Icons.logout, 'Keluar', () {
                    context.read<TiketProvider>().resetPromo();
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}