import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'services/tiket_service.dart';
import 'services/storage_service.dart';
import 'providers/tiket_provider.dart';
import 'screens/beranda_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final storage = await StorageService.init();
  final tiketService = TiketService(dio: Dio());
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TiketProvider(
            service: tiketService,
            storage: storage,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Tiket App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        
        // ✅ PERBAIKAN: CardTheme → CardThemeData
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        
        // ✅ PERBAIKAN: ElevatedButtonTheme → ElevatedButtonThemeData
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        
        // ✅ Tambahan: AppBar theme
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: const BerandaScreen(),
    );
  }
}