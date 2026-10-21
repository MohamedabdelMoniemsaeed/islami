import 'package:flutter/material.dart';
import 'package:islami/services/api_service.dart';
import 'package:islami/models/azkar_model.dart';

class AzkarScreen extends StatefulWidget {
  static const String routeName = '/azkar';
  const AzkarScreen({super.key});

  @override
  State<AzkarScreen> createState() => _AzkarScreenState();
}

class _AzkarScreenState extends State<AzkarScreen> {
  final ApiService _apiService = ApiService();
  late Future<AzkarResponse> _azkarFuture;

  @override
  void initState() {
    super.initState();
    _azkarFuture = _apiService.getAzkar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الأذكار')),
      body: FutureBuilder<AzkarResponse>(
        future: _azkarFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.azkar.isEmpty) {
            return const Center(child: Text('لا توجد أذكار متاحة حالياً'));
          }

          final azkar = snapshot.data!.azkar;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: azkar.length,
            itemBuilder: (context, index) {
              final zikr = azkar[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        zikr.category,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE2BE7F)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        zikr.description,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('التكرار: ${zikr.count}', style: const TextStyle(color: Colors.grey)),
                          Text(zikr.reference, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
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
