import 'package:flutter/material.dart';
import 'package:islami/services/api_service.dart';
import 'package:islami/models/tafsir_model.dart';

class TafsirDetailsScreen extends StatefulWidget {
  static const String routeName = '/tafsir-details';
  final int surahNumber;
  final String surahName;

  const TafsirDetailsScreen({
    super.key,
    required this.surahNumber,
    required this.surahName,
  });

  @override
  State<TafsirDetailsScreen> createState() => _TafsirDetailsScreenState();
}

class _TafsirDetailsScreenState extends State<TafsirDetailsScreen> {
  final ApiService _apiService = ApiService();
  late Future<TafsirResponse> _tafsirFuture;

  @override
  void initState() {
    super.initState();
    _tafsirFuture = _apiService.getTafsir(widget.surahNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('تفسير ${widget.surahName}')),
      body: FutureBuilder<TafsirResponse>(
        future: _tafsirFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.result.isEmpty) {
            return const Center(child: Text('تعذر تحميل التفسير، تأكد من الاتصال بالإنترنت'));
          }

          final items = snapshot.data!.result;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'آية ${item.aya}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE2BE7F)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.arabicText,
                        style: const TextStyle(fontSize: 18, height: 1.6),
                        textDirection: TextDirection.rtl,
                      ),
                      const Divider(height: 24),
                      Text(
                        item.translation,
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
