import 'package:flutter/material.dart';
import 'package:islami/Screen/HomeTab/tafsir_details_screen.dart';

class TafsirIndexScreen extends StatelessWidget {
  static const String routeName = '/tafsir-index';
  const TafsirIndexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التفسير الميسر')),
      body: ListView.builder(
        itemCount: 114,
        itemBuilder: (context, index) {
          final surahNum = index + 1;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFE2BE7F),
              child: Text('$surahNum', style: const TextStyle(color: Colors.black)),
            ),
            title: Text('سورة رقم $surahNum', style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TafsirDetailsScreen(surahNumber: surahNum, surahName: 'سورة $surahNum'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
