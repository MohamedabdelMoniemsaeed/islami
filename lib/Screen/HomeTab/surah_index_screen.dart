import 'package:flutter/material.dart';
import 'package:islami/services/api_service.dart';
import 'package:islami/Screen/HomeTab/tafsir_details_screen.dart';

class SurahIndexScreen extends StatefulWidget {
  static const String routeName = '/surah-index';
  const SurahIndexScreen({super.key});

  @override
  State<SurahIndexScreen> createState() => _SurahIndexScreenState();
}

class _SurahIndexScreenState extends State<SurahIndexScreen> {
  final ApiService _apiService = ApiService();
  late Future<dynamic> _surahsFuture;

  @override
  void initState() {
    super.initState();
    _surahsFuture = _apiService.getSurahsList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('فهرس السور'),
      ),
      body: FutureBuilder<dynamic>(
        future: _surahsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return Center(child: Text('خطأ في تحميل السور: ${snapshot.error}'));
          }
          final surahs = snapshot.data;
          if (surahs is! List || surahs.isEmpty) {
            return const Center(child: Text('لا توجد سور متاحة'));
          }

          return ListView.builder(
            itemCount: surahs.length,
            itemBuilder: (context, index) {
              final surah = surahs[index];
              final name = surah['name'] ?? surah['englishName'] ?? 'سورة ${index + 1}';
              final number = surah['number'] ?? (index + 1);
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFE2BE7F),
                  child: Text('$number', style: const TextStyle(color: Colors.black)),
                ),
                title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('رقم السورة: $number'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TafsirDetailsScreen(surahNumber: number, surahName: name),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
